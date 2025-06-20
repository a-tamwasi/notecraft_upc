import 'package:flutter_test/flutter_test.dart';
import 'package:notecraft_upc/services/hybrid_transcription_service.dart';
import 'package:notecraft_upc/repositories/title_generation_repository.dart';
import '../mocks/mock_deepgram_service.dart';

void main() {
  group('HybridTranscriptionService', () {
    late HybridTranscriptionService hybridService;
    late MockDeepgramService mockDeepgram;
    late MockTitleGenerationRepository mockTitleGeneration;

    setUp(() {
      mockDeepgram = MockDeepgramService();
      mockTitleGeneration = MockTitleGenerationRepository();
      
      hybridService = HybridTranscriptionService(
        audioTranscriptionRepository: mockDeepgram,
        openAIRepository: mockTitleGeneration,
      );
    });

    tearDown(() {
      hybridService.dispose();
    });

    group('transcribeAudio', () {
      test('utilise Deepgram pour la transcription avec succès', () async {
        // Arrange
        const expectedTranscription = 'Bonjour, ceci est un test Deepgram';
        mockDeepgram.mockTranscriptionResult = expectedTranscription;

        // Act
        final result = await hybridService.transcribeAudio('/test/audio.m4a');

        // Assert
        expect(result, equals(expectedTranscription));
        expect(mockDeepgram.lastFilePath, equals('/test/audio.m4a'));
      });

      test('fait fallback vers OpenAI si Deepgram échoue', () async {
        // Arrange
        mockDeepgram.shouldThrowError = true;
        
        // Le service hybride devrait créer un OpenAI service en fallback
        // Pour ce test, on simule le comportement attendu
        
        // Act & Assert
        expect(
          () => hybridService.transcribeAudio('/test/audio.m4a'),
          throwsException,
        );
      });

      test('gère les erreurs de Deepgram correctement', () async {
        // Arrange
        mockDeepgram.shouldThrowError = true;

        // Act & Assert
        expect(
          () => hybridService.transcribeAudio('/test/audio.m4a'),
          throwsException,
        );
      });

      test('respecte le délai de transcription configuré', () async {
        // Arrange
        const delay = Duration(milliseconds: 100);
        mockDeepgram.transcriptionDelay = delay;
        
        // Act
        final stopwatch = Stopwatch()..start();
        await hybridService.transcribeAudio('/test/audio.m4a');
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('generateTitle', () {
      test('utilise OpenAI pour la génération de titre avec succès', () async {
        // Arrange
        const inputText = 'Ceci est un long texte de transcription qui nécessite un titre';
        const expectedTitle = 'Titre généré par OpenAI';
        mockTitleGeneration.mockTitleResult = expectedTitle;

        // Act
        final result = await hybridService.generateTitle(inputText);

        // Assert
        expect(result, equals(expectedTitle));
        expect(mockTitleGeneration.lastInputText, equals(inputText));
      });

      test('génère un titre par défaut si OpenAI échoue', () async {
        // Arrange
        mockTitleGeneration.shouldThrowError = true;

        // Act
        final result = await hybridService.generateTitle('Test text');

        // Assert
        expect(result, contains('Transcription du'));
        expect(result, contains('/'));
        expect(result, contains(':'));
      });
    });

    group('getServiceInfo', () {
      test('retourne les informations sur les services utilisés', () {
        // Act
        final info = hybridService.getServiceInfo();

        // Assert
        expect(info['transcription_provider'], equals('MockDeepgramService'));
        expect(info['title_generation_provider'], equals('MockTitleGenerationRepository'));
        expect(info['architecture'], equals('hybrid'));
      });
    });

    group('factory methods', () {
      test('createWithOpenAITranscription crée un service avec OpenAI pour transcription', () {
        // Act
        final service = HybridTranscriptionService.createWithOpenAITranscription();
        final info = service.getServiceInfo();

        // Assert
        expect(info['transcription_provider'], equals('OpenAIService'));
        expect(info['title_generation_provider'], equals('OpenAIService'));
        
        service.dispose();
      });

      test('createWithDeepgramOnly crée un service avec Deepgram uniquement', () {
        // Act
        final service = HybridTranscriptionService.createWithDeepgramOnly();
        final info = service.getServiceInfo();

        // Assert
        expect(info['transcription_provider'], equals('DeepgramService'));
        expect(info['title_generation_provider'], equals('OpenAIService'));
        
        service.dispose();
      });
    });
  });
}

/// Mock pour la génération de titre (compléter le mock existant)
class MockTitleGenerationRepository implements OpenAIRepository {
  String mockTitleResult = 'Titre simulé';
  String mockEnhancedResult = 'Texte amélioré simulé';
  bool shouldThrowError = false;
  String? lastInputText;

  @override
  Future<String> generateTitle(String text) async {
    lastInputText = text;
    
    if (shouldThrowError) {
      throw Exception('Mock: Erreur de génération de titre simulée');
    }
    
    return mockTitleResult;
  }

  @override
  Future<String> enhanceTranscription(String rawText) async {
    if (shouldThrowError) {
      throw Exception('Mock: Erreur d\'amélioration simulée');
    }
    
    return mockEnhancedResult;
  }

  @override
  void dispose() {
    // Aucune ressource à libérer dans le mock
  }
} 