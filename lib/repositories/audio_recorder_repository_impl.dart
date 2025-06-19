import 'dart:async';
import '../controllers/audio_recorder_controller.dart';
import 'audio_repository.dart';

/// Implémentation concrète d'AudioRepository utilisant AudioRecorderController
/// 
/// TODO: Écrire des tests unitaires pour AudioRecorderRepositoryImpl
/// - Test d'initialisation avec permissions accordées/refusées
/// - Test du cycle complet d'enregistrement (start/pause/resume/stop)
/// - Test de gestion d'erreurs (microphone occupé, espace insuffisant)
/// - Test des getters d'état pendant l'enregistrement
/// - Mock d'AudioRecorderController pour tests isolés
class AudioRecorderRepositoryImpl implements AudioRepository {
  final AudioRecorderController _controller;
  late StreamController<int> _secondsStreamController;

  AudioRecorderRepositoryImpl({AudioRecorderController? controller})
      : _controller = controller ?? AudioRecorderController() {
    _initializeStream();
  }

  void _initializeStream() {
    _secondsStreamController = StreamController<int>.broadcast();
    _controller.secondesEcoulees.addListener(_onSecondsChanged);
  }

  void _onSecondsChanged() {
    _secondsStreamController.add(_controller.secondesEcoulees.value);
  }

  @override
  Future<void> initialize() async {
    await _controller.initialize();
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    return await _controller.requestMicrophonePermission();
  }

  @override
  Future<bool> startRecording() async {
    return await _controller.start();
  }

  @override
  Future<bool> pauseRecording() async {
    return await _controller.pause();
  }

  @override
  Future<bool> resumeRecording() async {
    return await _controller.resume();
  }

  @override
  Future<int?> stopRecording() async {
    return await _controller.stop();
  }

  @override
  bool get isRecording => _controller.isRecording;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  bool get isInitialized => _controller.isInitialized;

  @override
  String? get lastRecordingPath => _controller.lastRecordingPath;

  @override
  Stream<int> get secondsElapsedStream => _secondsStreamController.stream;

  /// Expose le contrôleur sous-jacent pour un accès direct (ex: ValueListenableBuilder)
  AudioRecorderController get controller => _controller;

  @override
  void reset() {
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.secondesEcoulees.removeListener(_onSecondsChanged);
    _secondsStreamController.close();
    _controller.dispose();
  }
} 