import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Contrôleur pour gérer l'enregistrement audio
/// Centralise toute la logique d'enregistrement, pause, reprise et arrêt
class AudioRecorderController extends ChangeNotifier {
  // --- //
  // 1. PROPRIÉTÉS PRIVÉES
  // --- //
  
  /// Instance de l'enregistreur audio
  AudioRecorder? _recorder;
  
  /// Timer pour compter les secondes d'enregistrement
  Timer? _timer;
  
  /// Chemin du fichier d'enregistrement actuel
  String? _recordingPath;
  
  /// États de l'enregistrement
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isInitialized = false;
  
  /// Notificateur pour les secondes écoulées (observable par les widgets)
  final ValueNotifier<int> _secondesEcoulees = ValueNotifier<int>(0);

  // --- //
  // 2. GETTERS PUBLICS
  // --- //
  
  /// Nombre de secondes écoulées depuis le début de l'enregistrement
  ValueNotifier<int> get secondesEcoulees => _secondesEcoulees;
  
  /// Indique si un enregistrement est en cours
  bool get isRecording => _isRecording;
  
  /// Indique si l'enregistrement est en pause
  bool get isPaused => _isPaused;
  
  /// Indique si le contrôleur est initialisé
  bool get isInitialized => _isInitialized;
  
  /// Chemin du dernier fichier enregistré
  String? get lastRecordingPath => _recordingPath;

  // --- //
  // 3. INITIALISATION
  // --- //
  
  /// Initialise le contrôleur et configure la session audio
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configuration de la session audio pour l'enregistrement
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      
      // Création de l'instance d'enregistrement
      _recorder = AudioRecorder();
      _isInitialized = true;
      
      debugPrint('AudioRecorderController initialisé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'audio: $e');
      rethrow;
    }
  }

  // --- //
  // 4. GESTION DES PERMISSIONS
  // --- //
  
  /// Vérifie et demande la permission du microphone
  Future<bool> requestMicrophonePermission() async {
    try {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Ouvre les paramètres de l'application si permission refusée définitivement
        await openAppSettings();
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la demande de permission microphone: $e');
      return false;
    }
  }

  // --- //
  // 5. GESTION DU CHEMIN D'ENREGISTREMENT
  // --- //
  
  /// Génère un chemin unique pour l'enregistrement audio
  Future<String> _getRecordingPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${directory.path}/recording_$timestamp.m4a';
    } catch (e) {
      debugPrint('Erreur lors de la génération du chemin d\'enregistrement: $e');
      rethrow;
    }
  }

  // --- //
  // 6. CONTRÔLE DU TIMER
  // --- //
  
  /// Démarre le timer pour compter les secondes
  void _startTimer() {
    _timer?.cancel(); // Annule le timer précédent s'il existe
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondesEcoulees.value++;
      notifyListeners(); // Notifie les widgets d'un changement d'état
    });
  }
  
  /// Met en pause le timer
  void _pauseTimer() {
    _timer?.cancel();
  }
  
  /// Reprend le timer (identique à _startTimer)
  void _resumeTimer() {
    _startTimer();
  }
  
  /// Arrête et remet à zéro le timer
  void _stopTimer() {
    _timer?.cancel();
    _secondesEcoulees.value = 0;
  }

  // --- //
  // 7. MÉTHODES PUBLIQUES D'ENREGISTREMENT
  // --- //
  
  /// Démarre un nouvel enregistrement audio
  Future<bool> start() async {
    if (!_isInitialized) {
      debugPrint('Contrôleur non initialisé. Appeler initialize() d\'abord.');
      return false;
    }
    
    if (_isRecording) {
      debugPrint('Un enregistrement est déjà en cours');
      return false;
    }
    
    try {
      // Vérification des permissions
      if (!await requestMicrophonePermission()) {
        debugPrint('Permission microphone refusée');
        return false;
      }
      
      // Génération du chemin de fichier
      _recordingPath = await _getRecordingPath();
      
      // Configuration optimisée pour la transcription Whisper
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC-LC optimal pour Whisper
          bitRate: 64000, // 64k suffisant pour la parole
          sampleRate: 16000, // 16kHz optimal pour Whisper
          numChannels: 1, // Mono pour réduire la taille
        ),
        path: _recordingPath!,
      );
      
      // Mise à jour des états
      _isRecording = true;
      _isPaused = false;
      _secondesEcoulees.value = 0;
      
      // Démarrage du timer
      _startTimer();
      
      notifyListeners();
      debugPrint('Enregistrement démarré: $_recordingPath');
      return true;
      
    } catch (e) {
      debugPrint('Erreur lors du démarrage de l\'enregistrement: $e');
      return false;
    }
  }
  
  /// Met en pause l'enregistrement en cours
  Future<bool> pause() async {
    if (!_isRecording || _isPaused) {
      debugPrint('Aucun enregistrement actif à mettre en pause');
      return false;
    }
    
    try {
      await _recorder!.pause();
      _isPaused = true;
      _pauseTimer();
      
      notifyListeners();
      debugPrint('Enregistrement mis en pause');
      return true;
      
    } catch (e) {
      debugPrint('Erreur lors de la mise en pause: $e');
      return false;
    }
  }
  
  /// Reprend l'enregistrement après une pause
  Future<bool> resume() async {
    if (!_isRecording || !_isPaused) {
      debugPrint('Aucun enregistrement en pause à reprendre');
      return false;
    }
    
    try {
      await _recorder!.resume();
      _isPaused = false;
      _resumeTimer();
      
      notifyListeners();
      debugPrint('Enregistrement repris');
      return true;
      
    } catch (e) {
      debugPrint('Erreur lors de la reprise: $e');
      return false;
    }
  }
  
  /// Arrête l'enregistrement et retourne la durée totale
  Future<int?> stop() async {
    if (!_isRecording) {
      debugPrint('Aucun enregistrement à arrêter');
      return null;
    }
    
    try {
      await _recorder!.stop();
      
      // Sauvegarde de la durée avant remise à zéro
      final dureeEnregistrement = _secondesEcoulees.value;
      
      // Remise à zéro des états
      _isRecording = false;
      _isPaused = false;
      _stopTimer();
      
      notifyListeners();
      debugPrint('Enregistrement arrêté. Durée: ${dureeEnregistrement}s');
      
      return dureeEnregistrement;
      
    } catch (e) {
      debugPrint('Erreur lors de l\'arrêt de l\'enregistrement: $e');
      return null;
    }
  }

  // --- //
  // 8. MÉTHODES UTILITAIRES
  // --- //
  
  /// Formate la durée en secondes au format MM:SS
  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
  
  /// Remet à zéro tous les états (sans arrêter un enregistrement en cours)
  void reset() {
    if (_isRecording) {
      debugPrint('Impossible de reset pendant un enregistrement');
      return;
    }
    
    _recordingPath = null;
    _secondesEcoulees.value = 0;
    notifyListeners();
    debugPrint('Contrôleur remis à zéro');
  }

  // --- //
  // 9. LIBÉRATION DES RESSOURCES
  // --- //
  
  @override
  void dispose() {
    // Arrêt de l'enregistrement s'il est en cours
    if (_isRecording) {
      _recorder?.stop();
    }
    
    // Nettoyage des ressources
    _timer?.cancel();
    _recorder?.dispose();
    _secondesEcoulees.dispose();
    
    debugPrint('AudioRecorderController libéré');
    super.dispose();
  }
} 