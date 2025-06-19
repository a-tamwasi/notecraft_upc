import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notecraft_upc/repositories/audio_repository.dart';
import 'package:notecraft_upc/repositories/transcription_repository.dart';
import 'package:notecraft_upc/repositories/export_repository.dart';
import 'package:notecraft_upc/repositories/credit_repository.dart';

/// Mock d'AudioRepository pour les tests unitaires
/// 
/// Exemple d'utilisation dans les tests :
/// ```dart
/// test('démarre l\'enregistrement avec succès', () async {
///   final mockRepo = MockAudioRepository();
///   mockRepo.shouldStartSucceed = true;
///   
///   final result = await mockRepo.startRecording();
///   expect(result, isTrue);
///   expect(mockRepo.isRecording, isTrue);
/// });
/// ```
class MockAudioRepository implements AudioRepository {
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _lastRecordingPath;
  
  final StreamController<int> _secondsController = StreamController<int>.broadcast();
  int _currentSeconds = 0;
  
  // Configuration pour contrôler le comportement dans les tests
  bool shouldStartSucceed = true;
  bool shouldInitializeSucceed = true;
  bool shouldRequestPermissionSucceed = true;
  String mockRecordingPath = '/mock/path/recording.m4a';
  int mockRecordingDuration = 30; // en secondes

  @override
  Future<void> initialize() async {
    if (!shouldInitializeSucceed) {
      throw Exception('Mock: Échec d\'initialisation');
    }
    _isInitialized = true;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    return shouldRequestPermissionSucceed;
  }

  @override
  Future<bool> startRecording() async {
    if (!shouldStartSucceed) return false;
    
    _isRecording = true;
    _isPaused = false;
    _lastRecordingPath = mockRecordingPath;
    _currentSeconds = 0;
    
    // Simuler le timer d'enregistrement
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && !_isPaused) {
        _currentSeconds++;
        _secondsController.add(_currentSeconds);
      } else {
        timer.cancel();
      }
    });
    
    return true;
  }

  @override
  Future<bool> pauseRecording() async {
    if (!_isRecording) return false;
    _isPaused = true;
    return true;
  }

  @override
  Future<bool> resumeRecording() async {
    if (!_isRecording || !_isPaused) return false;
    _isPaused = false;
    return true;
  }

  @override
  Future<int?> stopRecording() async {
    if (!_isRecording) return null;
    
    _isRecording = false;
    _isPaused = false;
    final duration = _currentSeconds;
    _currentSeconds = 0;
    
    return duration;
  }

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPaused => _isPaused;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get lastRecordingPath => _lastRecordingPath;

  @override
  Stream<int> get secondsElapsedStream => _secondsController.stream;

  @override
  void reset() {
    _isRecording = false;
    _isPaused = false;
    _lastRecordingPath = null;
    _currentSeconds = 0;
  }

  @override
  void dispose() {
    _secondsController.close();
  }
}

/// Mock de TranscriptionRepository pour les tests unitaires
/// 
/// Exemple d'utilisation :
/// ```dart
/// test('transcrit un fichier audio avec succès', () async {
///   final mockRepo = MockTranscriptionRepository();
///   mockRepo.mockTranscriptionResult = 'Transcription de test';
///   
///   final result = await mockRepo.transcribeAudio('/path/to/audio.m4a');
///   expect(result, equals('Transcription de test'));
/// });
/// ```
class MockTranscriptionRepository implements TranscriptionRepository {
  String mockTranscriptionResult = 'Transcription simulée par le mock';
  String mockTitleResult = 'Titre simulé';
  bool shouldThrowTranscriptionError = false;
  bool shouldThrowTitleError = false;
  Duration transcriptionDelay = Duration.zero;

  @override
  Future<String> transcribeAudio(String filePath) async {
    if (transcriptionDelay > Duration.zero) {
      await Future.delayed(transcriptionDelay);
    }
    
    if (shouldThrowTranscriptionError) {
      throw Exception('Mock: Erreur de transcription simulée');
    }
    
    return mockTranscriptionResult;
  }

  @override
  Future<String> generateTitle(String text) async {
    if (shouldThrowTitleError) {
      throw Exception('Mock: Erreur de génération de titre simulée');
    }
    
    return mockTitleResult;
  }

  @override
  void dispose() {
    // Aucune ressource à libérer dans le mock
  }
}

/// Mock d'ExportRepository pour les tests unitaires
/// 
/// Exemple d'utilisation :
/// ```dart
/// test('exporte en PDF avec succès', () async {
///   final mockRepo = MockExportRepository();
///   mockRepo.shouldExportSucceed = true;
///   
///   final result = await mockRepo.exportToPdf('Texte à exporter', context);
///   expect(result, isTrue);
///   expect(mockRepo.lastExportedText, equals('Texte à exporter'));
/// });
/// ```
class MockExportRepository implements ExportRepository {
  bool shouldExportSucceed = true;
  String? lastExportedText;
  String? lastExportFormat;
  int mockTextSize = 1024; // en bytes

  @override
  Future<bool> exportToTxt(String text, BuildContext context) async {
    lastExportedText = text;
    lastExportFormat = 'TXT';
    
    if (!shouldExportSucceed) {
      throw Exception('Mock: Échec d\'export TXT simulé');
    }
    
    return true;
  }

  @override
  Future<bool> exportToPdf(String text, BuildContext context) async {
    lastExportedText = text;
    lastExportFormat = 'PDF';
    
    if (!shouldExportSucceed) {
      throw Exception('Mock: Échec d\'export PDF simulé');
    }
    
    return true;
  }

  @override
  bool canExport(String text) {
    return text.trim().isNotEmpty;
  }

  @override
  int getTextSize(String text) {
    return mockTextSize;
  }

  @override
  String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Mock de CreditRepository pour les tests unitaires
/// 
/// Exemple d'utilisation :
/// ```dart
/// test('déduit les crédits correctement', () {
///   final mockRepo = MockCreditRepository();
///   mockRepo.setInitialCredits(600); // 10 minutes
///   
///   mockRepo.deductCredits(120); // 2 minutes utilisées
///   expect(mockRepo.remainingCreditSeconds, equals(480)); // 8 minutes restantes
/// });
/// ```
class MockCreditRepository implements CreditRepository {
  int _totalCredits = 600; // 10 minutes par défaut
  int _remainingCredits = 600;
  
  final StreamController<int> _creditsController = StreamController<int>.broadcast();

  void setInitialCredits(int seconds) {
    _totalCredits = seconds;
    _remainingCredits = seconds;
    _creditsController.add(_remainingCredits);
  }

  @override
  int get remainingCreditSeconds => _remainingCredits;

  @override
  int get totalCreditSeconds => _totalCredits;

  @override
  bool hasEnoughCredits(int secondsNeeded) {
    return _remainingCredits >= secondsNeeded;
  }

  @override
  void deductCredits(int secondsUsed) {
    _remainingCredits = (_remainingCredits - secondsUsed).clamp(0, _totalCredits);
    _creditsController.add(_remainingCredits);
  }

  @override
  void addCredits(int secondsToAdd) {
    _totalCredits += secondsToAdd;
    _remainingCredits += secondsToAdd;
    _creditsController.add(_remainingCredits);
  }

  @override
  Future<void> loadCredits() async {
    // Mock: simule le chargement depuis le stockage persistant
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> saveCredits() async {
    // Mock: simule la sauvegarde vers le stockage persistant
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  void resetCredits() {
    _totalCredits = 600;
    _remainingCredits = 600;
    _creditsController.add(_remainingCredits);
  }

  @override
  Stream<int> get creditsStream => _creditsController.stream;

  void dispose() {
    _creditsController.close();
  }
} 