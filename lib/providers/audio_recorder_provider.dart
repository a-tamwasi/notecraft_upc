import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/audio_repository.dart';
import 'dependency_providers.dart';

/// État de l'enregistreur audio
class AudioRecorderState {
  final bool isRecording;
  final bool isPaused;
  final bool isInitialized;
  final int secondesEcoulees;
  final String? lastRecordingPath;
  final String? errorMessage;

  const AudioRecorderState({
    this.isRecording = false,
    this.isPaused = false,
    this.isInitialized = false,
    this.secondesEcoulees = 0,
    this.lastRecordingPath,
    this.errorMessage,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    bool? isPaused,
    bool? isInitialized,
    int? secondesEcoulees,
    String? lastRecordingPath,
    String? errorMessage,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      isInitialized: isInitialized ?? this.isInitialized,
      secondesEcoulees: secondesEcoulees ?? this.secondesEcoulees,
      lastRecordingPath: lastRecordingPath ?? this.lastRecordingPath,
      errorMessage: errorMessage,
    );
  }

  /// Formate la durée en secondes au format MM:SS
  String get formattedDuration {
    final minutes = (secondesEcoulees ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (secondesEcoulees % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}

/// StateNotifier pour gérer l'enregistrement audio avec injection de dépendances
/// 
/// TODO: Écrire des tests unitaires pour AudioRecorderNotifier
/// - Test avec mock d'AudioRepository
/// - Test de gestion d'états pendant l'enregistrement
/// - Test de gestion d'erreurs et récupération
/// - Test de synchronisation avec streams
class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  final AudioRepository _repository;

  AudioRecorderNotifier(this._repository) : super(const AudioRecorderState()) {
    _initializeRepository();
  }

  /// Initialise le repository et configure les listeners
  Future<void> _initializeRepository() async {
    try {
      await _repository.initialize();
      
      // Écoute des changements du repository via stream
      // Le listener sera automatiquement fermé quand le StateNotifier est disposé
      _repository.secondsElapsedStream.listen(_onSecondsChanged);
      
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état
      // Évite les mises à jour après dispose du provider
      if (mounted) {
        state = state.copyWith(
          isInitialized: _repository.isInitialized,
          errorMessage: null,
        );
      }
    } catch (e) {
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état d'erreur
      // Évite les crash lors d'initialisation après dispose
      if (mounted) {
        state = state.copyWith(
          errorMessage: 'Erreur d\'initialisation: $e',
        );
      }
    }
  }

  /// Met à jour les secondes écoulées
  void _onSecondsChanged(int seconds) {
    // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état
    // Évite les mises à jour de secondes après dispose du provider
    if (!mounted) return;
    
    state = state.copyWith(
      secondesEcoulees: seconds,
      isRecording: _repository.isRecording,
      isPaused: _repository.isPaused,
      lastRecordingPath: _repository.lastRecordingPath,
    );
  }

  /// Démarre l'enregistrement
  Future<bool> startRecording() async {
    try {
      state = state.copyWith(errorMessage: null);
      final success = await _repository.startRecording();
      
      if (!success) {
        state = state.copyWith(
          errorMessage: 'Impossible de démarrer l\'enregistrement',
        );
      } else {
        _updateStateFromRepository();
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors du démarrage: $e',
      );
      return false;
    }
  }

  /// Met en pause l'enregistrement
  Future<bool> pauseRecording() async {
    try {
      state = state.copyWith(errorMessage: null);
      final success = await _repository.pauseRecording();
      
      if (!success) {
        state = state.copyWith(
          errorMessage: 'Impossible de mettre en pause',
        );
      } else {
        _updateStateFromRepository();
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors de la pause: $e',
      );
      return false;
    }
  }

  /// Reprend l'enregistrement
  Future<bool> resumeRecording() async {
    try {
      state = state.copyWith(errorMessage: null);
      final success = await _repository.resumeRecording();
      
      if (!success) {
        state = state.copyWith(
          errorMessage: 'Impossible de reprendre l\'enregistrement',
        );
      } else {
        _updateStateFromRepository();
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors de la reprise: $e',
      );
      return false;
    }
  }

  /// Arrête l'enregistrement
  Future<int?> stopRecording() async {
    try {
      state = state.copyWith(errorMessage: null);
      final duration = await _repository.stopRecording();
      
      if (duration == null) {
        state = state.copyWith(
          errorMessage: 'Erreur lors de l\'arrêt de l\'enregistrement',
        );
      } else {
        _updateStateFromRepository();
      }
      
      return duration;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors de l\'arrêt: $e',
      );
      return null;
    }
  }

  /// Remet à zéro l'enregistreur
  void reset() {
    try {
      _repository.reset();
      _updateStateFromRepository();
      state = state.copyWith(errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors de la remise à zéro: $e',
      );
    }
  }

  /// Met à jour l'état depuis le repository
  void _updateStateFromRepository() {
    state = state.copyWith(
      isRecording: _repository.isRecording,
      isPaused: _repository.isPaused,
      isInitialized: _repository.isInitialized,
      lastRecordingPath: _repository.lastRecordingPath,
    );
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

/// Provider pour l'enregistreur audio avec injection de dépendances
final audioRecorderProvider = StateNotifierProvider<AudioRecorderNotifier, AudioRecorderState>((ref) {
  final audioRepository = ref.watch(audioRepositoryProvider);
  return AudioRecorderNotifier(audioRepository);
}); 