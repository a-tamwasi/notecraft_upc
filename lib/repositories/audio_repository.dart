import 'dart:async';

/// Interface abstraite pour l'enregistrement audio
/// Permet de mocker facilement pour les tests unitaires
abstract class AudioRepository {
  /// Initialise le système d'enregistrement audio
  Future<void> initialize();
  
  /// Vérifie et demande la permission du microphone
  Future<bool> requestMicrophonePermission();
  
  /// Démarre un nouvel enregistrement audio
  /// Retourne true si le démarrage a réussi
  Future<bool> startRecording();
  
  /// Met en pause l'enregistrement en cours
  /// Retourne true si la pause a réussi
  Future<bool> pauseRecording();
  
  /// Reprend l'enregistrement après une pause
  /// Retourne true si la reprise a réussi
  Future<bool> resumeRecording();
  
  /// Arrête l'enregistrement et retourne la durée totale en secondes
  /// Retourne null en cas d'erreur
  Future<int?> stopRecording();
  
  /// Indique si un enregistrement est en cours
  bool get isRecording;
  
  /// Indique si l'enregistrement est en pause
  bool get isPaused;
  
  /// Indique si le système est initialisé
  bool get isInitialized;
  
  /// Chemin du dernier fichier enregistré
  String? get lastRecordingPath;
  
  /// Stream des secondes écoulées pendant l'enregistrement
  Stream<int> get secondsElapsedStream;
  
  /// Remet à zéro tous les états (sans arrêter un enregistrement en cours)
  void reset();
  
  /// Libère les ressources
  void dispose();
} 