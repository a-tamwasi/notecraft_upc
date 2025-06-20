import 'package:notecraft_upc/repositories/audio_transcription_repository.dart';

/// Mock du service Deepgram pour les tests unitaires
/// 
/// Exemple d'utilisation :
/// ```dart
/// test('transcrit un fichier audio avec Deepgram', () async {
///   final mockService = MockDeepgramService();
///   mockService.mockTranscriptionResult = 'Transcription de test Deepgram';
///   
///   final result = await mockService.transcribeAudio('/path/to/audio.m4a');
///   expect(result, equals('Transcription de test Deepgram'));
/// });
/// ```
class MockDeepgramService implements AudioTranscriptionRepository {
  String mockTranscriptionResult = 'Transcription simulée par le mock Deepgram';
  bool shouldThrowError = false;
  Duration transcriptionDelay = Duration.zero;
  String? lastFilePath;

  @override
  Future<String> transcribeAudio(String filePath) async {
    lastFilePath = filePath;
    
    if (transcriptionDelay > Duration.zero) {
      await Future.delayed(transcriptionDelay);
    }
    
    if (shouldThrowError) {
      throw Exception('Mock Deepgram: Erreur de transcription simulée');
    }
    
    return mockTranscriptionResult;
  }

  @override
  void dispose() {
    // Aucune ressource à libérer dans le mock
  }

  /// Reset les paramètres du mock
  void reset() {
    mockTranscriptionResult = 'Transcription simulée par le mock Deepgram';
    shouldThrowError = false;
    transcriptionDelay = Duration.zero;
    lastFilePath = null;
  }
} 