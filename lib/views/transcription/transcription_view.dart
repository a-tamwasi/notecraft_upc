import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audioplayer;
import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/openai_service.dart';
import '../../services/pdf_service.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../abonnement/abonnement_page.dart';
import '../../controllers/navigation_notifier.dart';
import '../../services/credit_service.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/database/database_service.dart';
import '../../models/note_model.dart';
import '../../notifiers/history_notifier.dart';
import 'package:intl/intl.dart';

/// Vue principale pour la transcription audio
/// Affiche l'interface utilisateur pour enregistrer ou importer des audios
class TranscriptionView extends StatefulWidget {
  const TranscriptionView({Key? key}) : super(key: key);

  @override
  _TranscriptionViewState createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isImporting = false;
  bool _isTranscribing = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  AudioRecorder? _recorder;
  String? _recordingPath;
  String? _transcriptionResult;
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _transcriptionController = TextEditingController();
  final audioplayer.AudioPlayer _audioPlayer = audioplayer.AudioPlayer();

  // La gestion des crédits est maintenant déléguée au CreditService.

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    // Écoute les changements du service de crédits pour reconstruire le widget.
    creditService.addListener(_onCreditsChanged);
  }

  Future<void> _initializeAudio() async {
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
    
    _recorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder?.dispose();
    _transcriptionController.dispose();
    _audioPlayer.dispose();
    // Cesse d'écouter les changements pour éviter les fuites de mémoire.
    creditService.removeListener(_onCreditsChanged);
    super.dispose();
  }

  // Déclenche une reconstruction du widget lorsque les crédits changent.
  void _onCreditsChanged() {
    setState(() {
      // Le contenu du widget sera reconstruit avec les nouvelles valeurs du service.
    });
  }

  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<bool> _requestStoragePermission() async {
    // Sur Android 13+, on demande la permission audio spécifique.
    // Sinon, on demande le stockage général.
    final permission = Permission.audio;
    var status = await permission.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<String> _getRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.m4a';
  }

  void _toggleRecording() async {
    if (creditService.remainingCreditSeconds <= 0) {
      _montrerAlerteCreditEpuise();
      return;
    }
    if (!await _requestMicrophonePermission()) return;

    if (_isRecording && !_isPaused) {
      // Mettre en pause l'enregistrement
      await _pauseRecording();
    } else if (_isRecording && _isPaused) {
      // Reprendre l'enregistrement
      await _resumeRecording();
    } else {
      // Commencer l'enregistrement
      await _startRecording();
    }
  }

  void _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      await _recorder!.stop();
      _timer?.cancel();
      
      final int dureeEnregistrement = _secondsElapsed;

      setState(() {
        _isRecording = false;
        _isPaused = false;
        // Réinitialiser le chronomètre à zéro après arrêt
        _secondsElapsed = 0;
      });

      // Lancer automatiquement la transcription
      if (_recordingPath != null) {
        await _transcribeAudio(_recordingPath!, dureeEnregistrement);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'arrêt de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      _recordingPath = await _getRecordingPath();
      
      // Configuration optimisée pour la transcription
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC-LC optimal pour Whisper
          bitRate: 64000, // Réduit de 128k à 64k (suffisant pour la parole)
          sampleRate: 16000, // Réduit de 44.1k à 16k (optimal pour Whisper)
          numChannels: 1, // Mono au lieu de stéréo (plus petit fichier)
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _secondsElapsed = 0;
        _transcriptionResult = null;
      });

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du démarrage de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder!.pause();
      _timer?.cancel();
      
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la pause de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder!.resume();
      
      setState(() {
        _isPaused = false;
      });

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la reprise de l\'enregistrement: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });

        // Arrêter l'enregistrement si le crédit est épuisé
        if (_secondsElapsed >= creditService.remainingCreditSeconds) {
          _stopRecording();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Crédit de transcription épuisé. Enregistrement arrêté.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  Future<void> _transcribeAudio(String filePath, int audioDurationInSeconds) async {
    if (creditService.remainingCreditSeconds <= 0) {
      _montrerAlerteCreditEpuise();
      return;
    }

    setState(() {
      _isTranscribing = true;
      _transcriptionResult = null;
      _transcriptionController.text = '';
    });

    try {
      final transcription = await _openAIService.transcrireAudio(filePath);
      
      creditService.deductCredits(audioDurationInSeconds);

      _transcriptionController.text = transcription;
      setState(() {
        _transcriptionResult = transcription;
      });

      String titre;
      try {
        titre = await _openAIService.genererTitrePourTexte(transcription);
      } catch (e) {
        print('Erreur lors de la génération du titre : $e. Utilisation d\'un titre par défaut.');
        titre = 'Transcription du ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}';
      }

      await _sauvegarderAutomatiquementLaNote(
        titre: titre,
        transcription: transcription,
        dureeEnregistrement: audioDurationInSeconds,
        cheminAudio: filePath,
      );

    } on OpenAIException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de transcription: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur inattendue est survenue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTranscribing = false;
        // On ne supprime plus le fichier ici car son chemin est sauvegardé
        // La gestion du cycle de vie des fichiers audio devra être faite ailleurs
      });
    }
  }

  Future<void> _importAndUploadAudio() async {
    if (!await _requestStoragePermission()) return;

    setState(() => _isImporting = true);

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        
        // Estimation conservatrice de la durée basée sur la taille du fichier
        // 1 MB ≈ 1 minute d'audio (estimation très approximative)
        final fileSizeInBytes = result.files.single.size;
        final estimatedDurationSeconds = (fileSizeInBytes / (1024 * 1024) * 60).round();
        
        // Procéder directement à la transcription avec l'estimation
        await _transcribeAudio(filePath, estimatedDurationSeconds);
      } else {
        print("Aucun fichier sélectionné.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir la hauteur de la BottomNavigationBar pour éviter le chevauchement
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 
                         MediaQuery.of(context).padding.bottom + 
                         kBottomNavigationBarHeight + 
                         DimensionsApplication.paddingM;

    return Scaffold(
      backgroundColor: CouleursApplication.fondPrincipal,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: DimensionsApplication.paddingM,
            right: DimensionsApplication.paddingM,
            top: DimensionsApplication.paddingM,
            bottom: bottomPadding, // Padding dynamique pour éviter le chevauchement
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _construireSectionRappelCredit(),
              const SizedBox(height: DimensionsApplication.margeSection),
              _construireSectionEnregistrement(),
              const SizedBox(height: DimensionsApplication.margeSection),
              if (_transcriptionResult != null) _construireSectionTranscription(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la section de rappel des crédits de transcription (version discrète)
  Widget _construireSectionRappelCredit() {
    final remainingCreditSeconds = creditService.remainingCreditSeconds;
    final totalCreditSeconds = creditService.totalCreditSeconds;
    final remainingMinutes = (remainingCreditSeconds / 60).floor();
    final totalMinutes = (totalCreditSeconds / 60).floor();
    final progress = (totalCreditSeconds > 0) ? remainingCreditSeconds / totalCreditSeconds : 0.0;

    return Card(
      elevation: 2.0, // Ombre plus subtile
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        // Padding réduit pour un design plus compact
        padding: const EdgeInsets.symmetric(
            vertical: DimensionsApplication.paddingM,
            horizontal: DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey[600], // Icône plus claire
                        size: 20, // Icône plus petite
                      ),
                      const SizedBox(width: DimensionsApplication.paddingS),
                      Flexible(
                        child: Text(
                          '$remainingMinutes min',
                          style: StylesTexte.corps.copyWith(fontSize: 14, color: Colors.grey[800]),
                          overflow: TextOverflow.ellipsis, // Empêche le texte de déborder
                          softWrap: false, // Empêche le retour à la ligne
                        ),
                      ),
                      
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Ajoute un espacement de sécurité
                // --- Le nouveau bouton, repensé pour l'esthétique et la clarté ---
                FilledButton.tonalIcon(
                  onPressed: _acheterPlusDeCredits,
                  icon: const Icon(Iconsax.add_square, size: 18),
                  label: const Text('Recharger'),
                  style: FilledButton.styleFrom(
                    // Utilise les couleurs du thème pour une intégration parfaite
                    foregroundColor: CouleursApplication.primaire,
                    backgroundColor: CouleursApplication.primaire.withOpacity(0.1),
                    // Un padding équilibré pour une apparence soignée
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    // Un style de texte cohérent avec le reste de l'application
                    textStyle: StylesTexte.corpsPetit.copyWith(fontWeight: FontWeight.bold),
                    // Assure que le bouton ne prend pas plus de place que nécessaire
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // Une bordure subtile pour délimiter le bouton
                    side: BorderSide(color: CouleursApplication.primaire.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            // Barre de progression plus fine
            ClipRRect(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6, // Hauteur réduite
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(CouleursApplication.primaire),
              ),
            ),
            const SizedBox(height: DimensionsApplication.paddingS),
            Text(
              '$remainingMinutes min restantes sur $totalMinutes min',
              // Texte plus petit et discret
              style: StylesTexte.corpsPetit.copyWith(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la section d'enregistrement audio
  Widget _construireSectionEnregistrement() {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: DimensionsApplication.paddingXL,
            horizontal: DimensionsApplication.paddingL),
        child: Column(
          children: [
            // Bouton principal (Enregistrer/Pause/Reprendre)
            ElevatedButton.icon(
              onPressed: (_isImporting || _isTranscribing) ? null : _toggleRecording,
              icon: Icon(
                _isRecording 
                  ? (_isPaused ? Icons.play_arrow : Icons.pause)
                  : Icons.mic, 
                color: Colors.white
              ),
              label: Text(
                _isRecording 
                  ? (_isPaused ? 'Reprendre l\'enregistrement' : 'Mettre en pause')
                  : 'Enregistrer Audio',
                style: StylesTexte.corps.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording 
                  ? (_isPaused ? Colors.green : Colors.orange)
                  : CouleursApplication.primaire,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: DimensionsApplication.paddingM,
                  horizontal: DimensionsApplication.paddingL,
                ),
              ),
            ),
            // Bouton d'arrêt (visible seulement pendant l'enregistrement)
            if (_isRecording) ...[
              const SizedBox(height: DimensionsApplication.paddingM),
              ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: Text(
                  'Arrêter l\'enregistrement',
                  style: StylesTexte.corps.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: DimensionsApplication.paddingM,
                    horizontal: DimensionsApplication.paddingL,
                  ),
                ),
              ),
            ],
            const SizedBox(height: DimensionsApplication.margeGrande),
            Text(
              _formatDuration(_secondsElapsed),
              style: StylesTexte.titrePrincipal.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            if (_isTranscribing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: DimensionsApplication.paddingM),
                  Text('Transcription en cours...'),
                ],
              )
            else if (_isImporting)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: DimensionsApplication.paddingM),
                  Text('Importation en cours...'),
                ],
              )
            else
              _buildImportButton(),
          ],
        ),
      ),
    );
  }

  Widget _construireSectionTranscription() {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et menu d'actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.text_snippet,
                      color: CouleursApplication.primaire,
                      size: DimensionsApplication.iconeL,
                    ),
                    const SizedBox(width: DimensionsApplication.paddingS),
                    Text(
                      'Transcription',
                      style: StylesTexte.titreSection,
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: CouleursApplication.primaire,
                    size: 24,
                  ),
                  tooltip: 'Options',
                  color: Colors.white.withOpacity(0.95),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (String value) async {
                    switch (value) {
                      case 'exporter_pdf':
                        await _exporterPdf();
                        break;
                      case 'exporter_txt':
                        await _exporterTxt();
                        break;
                      case 'sauvegarder':
                        setState(() {
                          _transcriptionResult = _transcriptionController.text;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transcription sauvegardée !')),
                        );
                        break;
                      case 'supprimer':
                        _confirmerSuppression();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'sauvegarder',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.save, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Text('Sauvegarder', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'exporter_pdf',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Exporter en PDF', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'exporter_txt',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.text_snippet, color: Colors.green, size: 20),
                            SizedBox(width: 12),
                            Text('Exporter en TXT', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'supprimer',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Supprimer', style: TextStyle(fontSize: 15, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DimensionsApplication.paddingM),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 120, // Hauteur minimale pour assurer la visibilité
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Maximum 40% de l'écran
              ),
              decoration: BoxDecoration(
                color: CouleursApplication.fondPrincipal,
                borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
                border: Border.all(color: CouleursApplication.bordure),
              ),
              child: TextFormField(
                controller: _transcriptionController,
                maxLines: null,
                minLines: 5,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight + 20,
                ),
                decoration: InputDecoration(
                  hintText: 'Votre transcription apparaîtra ici. Vous pouvez la modifier...',
                  hintStyle: StylesTexte.corpsSecondaire,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(DimensionsApplication.paddingM),
                ),
                style: StylesTexte.corps,
                onChanged: (value) {
                  // Optionnel : vous pouvez ajouter une logique ici si nécessaire
                },
              ),
            ),
            const SizedBox(height: DimensionsApplication.paddingS),
            Text(
              'Conseil : Vous pouvez modifier le texte directement dans le champ ci-dessus.',
              style: StylesTexte.corpsPetit.copyWith(
                color: CouleursApplication.texteSecondaire,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

    /// Construit le bouton d'importation harmonisé
  Widget _buildImportButton() {
    return ElevatedButton.icon(
      onPressed: (_isRecording || _isTranscribing) ? null : _importAndUploadAudio,
      icon: const Icon(Icons.upload_file, color: Colors.white),
      label: Text(
        'Importer un fichier audio',
        style: StylesTexte.corps.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApplication.secondaire,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: DimensionsApplication.paddingM,
          horizontal: DimensionsApplication.paddingL,
        ),
      ),
    );
  }

  /// Confirme la suppression de la transcription
  void _confirmerSuppression() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette transcription ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _transcriptionResult = null;
                  _transcriptionController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transcription supprimée')),
                );
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Exporte la transcription en fichier TXT
  Future<void> _exporterTxt() async {
    if (_transcriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transcription à exporter !')),
      );
      return;
    }

    try {
      // Générer un nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_$formattedDate.txt';

      // Créer le contenu du fichier avec métadonnées
      final content = '''NoteCraft - Transcription Audio
Date de création: ${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}
Nombre de caractères: ${_transcriptionController.text.length}
Nombre de mots: ${_transcriptionController.text.split(' ').where((word) => word.isNotEmpty).length}

=====================================
CONTENU DE LA TRANSCRIPTION
=====================================

${_transcriptionController.text}

=====================================
Généré par NoteCraft App
=====================================''';

      // Convertir le contenu en bytes
      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      // Utiliser file_saver pour permettre à l'utilisateur de choisir l'emplacement
      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        ext: 'txt',
        mimeType: MimeType.text,
      );

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      if (filePath != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Fichier TXT exporté avec succès !'),
                Text('📁 $fileName'),
                Text('📊 Taille: ${(bytes.length / 1024).toStringAsFixed(1)} KB'),
                Text('📍 Sauvegardé à l\'emplacement choisi'),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Voir le chemin',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Fichier sauvegardé'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du fichier: $fileName'),
                        const SizedBox(height: 8),
                        const Text('Emplacement:'),
                        SelectableText(filePath),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // L'utilisateur a annulé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportation annulée par l\'utilisateur')),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'exportation TXT: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      print('Erreur exportation TXT: $e');
    }
  }

  /// Exporte la transcription en PDF
  Future<void> _exporterPdf() async {
    if (_transcriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transcription à exporter !')),
      );
      return;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Génération du PDF...'),
            ],
          ),
        ),
      );

      // Générer un nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_$formattedDate.pdf';

      // Générer le PDF en mémoire
      final String tempFilePath = await PdfService.exporterTranscriptionPdf(
        transcription: _transcriptionController.text,
        fileName: fileName,
      );

      // Lire le fichier PDF généré
      final File tempFile = File(tempFilePath);
      final Uint8List pdfBytes = await tempFile.readAsBytes();

      // Mettre à jour le message de chargement
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      // Utiliser file_saver pour permettre à l'utilisateur de choisir l'emplacement
      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      // Supprimer le fichier temporaire
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      if (filePath != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ PDF exporté avec succès !'),
                Text('📁 $fileName'),
                Text('📊 Taille: ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB'),
                Text('📍 Sauvegardé à l\'emplacement choisi'),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Voir le chemin',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('PDF sauvegardé'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du fichier: $fileName'),
                        const SizedBox(height: 8),
                        const Text('Emplacement:'),
                        SelectableText(filePath),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // L'utilisateur a annulé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportation annulée par l\'utilisateur')),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'exportation PDF: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      print('Erreur exportation PDF: $e');
    }
  }

  /// Gère la navigation vers la page d'achat et la mise à jour des crédits
  Future<void> _acheterPlusDeCredits() async {
    // Met à jour la valeur du notificateur pour demander le changement vers l'onglet 3 (Abonnement).
    navigationNotifier.value = 3;
  }

  /// Affiche une alerte si le crédit est insuffisant pour une transcription
  void _montrerAlerteCreditInsuffisant(int dureeRequiseSecondes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crédit insuffisant'),
        content: Text(
          'Il vous faut au moins ${(dureeRequiseSecondes / 60).ceil()} minutes pour transcrire ce fichier, mais il ne vous reste que ${(creditService.remainingCreditSeconds / 60).floor()} minutes.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acheterPlusDeCredits();
            },
            child: const Text('Acheter plus'),
          ),
        ],
      ),
    );
  }

  /// Affiche une alerte si le crédit est totalement épuisé
  void _montrerAlerteCreditEpuise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crédit épuisé'),
        content: const Text('Vous n\'avez plus de minutes de transcription. Veuillez en acheter pour continuer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acheterPlusDeCredits();
            },
            child: const Text('Acheter plus'),
          ),
        ],
      ),
    );
  }

  Future<void> _sauvegarderAutomatiquementLaNote({
    required String titre,
    required String transcription,
    required int dureeEnregistrement,
    required String cheminAudio,
  }) async {
    try {
      final nouvelleNote = Note(
        titre: titre,
        contenu: transcription,
        dateCreation: DateTime.now(),
        duree: dureeEnregistrement,
        cheminAudio: cheminAudio,
        langue: 'fr-FR', // Pour l'instant, la langue est définie ici
      );

      await DatabaseService.instance.create(nouvelleNote);
      print('Note sauvegardée avec succès dans la base de données.');

      // Notifier la page d'historique qu'une nouvelle note a été ajoutée
      historyNotifier.notifyHistoryChanged();

    } catch (e) {
      print('Erreur lors de la sauvegarde automatique de la note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde de la note: $e')),
      );
    }
  }
} 