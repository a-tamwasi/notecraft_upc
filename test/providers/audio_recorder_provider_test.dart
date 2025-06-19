import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notecraft_upc/providers/audio_recorder_provider.dart';
import '../mocks/mock_repositories.dart';

/// Tests unitaires pour AudioRecorderProvider avec injection de dépendances
/// 
/// Ces tests illustrent comment :
/// 1. Injecter des mocks dans les providers Riverpod
/// 2. Tester les changements d'état réactifs
/// 3. Vérifier les interactions avec les repositories
/// 4. Tester la gestion d'erreurs
/// 
/// Pour exécuter : flutter test test/providers/audio_recorder_provider_test.dart
void main() {
  group('AudioRecorderProvider Tests', () {
    late MockAudioRepository mockAudioRepository;
    late ProviderContainer container;

    setUp(() {
      mockAudioRepository = MockAudioRepository();
      
      // Créer un container avec le mock injecté
      container = ProviderContainer(
        overrides: [
          audioRecorderProvider.overrideWith((ref) {
            return AudioRecorderNotifier(mockAudioRepository);
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('état initial est correct', () {
      final state = container.read(audioRecorderProvider);
      
      expect(state.isRecording, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.secondesEcoulees, equals(0));
      expect(state.lastRecordingPath, isNull);
      expect(state.errorMessage, isNull);
    });

    test('démarre l\'enregistrement avec succès', () async {
      final notifier = container.read(audioRecorderProvider.notifier);
      
      // Configuration du mock
      mockAudioRepository.shouldStartSucceed = true;
      mockAudioRepository.shouldInitializeSucceed = true;
      
      // Initialisation
      await notifier.startRecording();
      
      final state = container.read(audioRecorderProvider);
      expect(state.isRecording, isTrue);
      expect(state.isPaused, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('gère les erreurs de démarrage d\'enregistrement', () async {
      final notifier = container.read(audioRecorderProvider.notifier);
      
      // Configuration du mock pour échouer
      mockAudioRepository.shouldStartSucceed = false;
      
      final result = await notifier.startRecording();
      
      expect(result, isFalse);
      final state = container.read(audioRecorderProvider);
      expect(state.isRecording, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage!.contains('Impossible de démarrer'), isTrue);
    });

    test('cycle complet d\'enregistrement : start -> pause -> resume -> stop', () async {
      final notifier = container.read(audioRecorderProvider.notifier);
      
      // Configuration du mock
      mockAudioRepository.shouldStartSucceed = true;
      
      // 1. Démarrer l'enregistrement
      await notifier.startRecording();
      expect(container.read(audioRecorderProvider).isRecording, isTrue);
      expect(container.read(audioRecorderProvider).isPaused, isFalse);
      
      // 2. Mettre en pause
      await notifier.pauseRecording();
      expect(container.read(audioRecorderProvider).isRecording, isTrue);
      expect(container.read(audioRecorderProvider).isPaused, isTrue);
      
      // 3. Reprendre
      await notifier.resumeRecording();
      expect(container.read(audioRecorderProvider).isRecording, isTrue);
      expect(container.read(audioRecorderProvider).isPaused, isFalse);
      
      // 4. Arrêter
      final duration = await notifier.stopRecording();
      expect(duration, isNotNull);
      expect(container.read(audioRecorderProvider).isRecording, isFalse);
      expect(container.read(audioRecorderProvider).isPaused, isFalse);
    });

    test('formatage de durée fonctionne correctement', () {
      final state = container.read(audioRecorderProvider);
      
      // Test du getter formattedDuration
      // Note: Cette partie dépend de l'implémentation actuelle
      expect(state.formattedDuration, equals('00:00'));
    });

    test('reset remet à zéro tous les états', () async {
      final notifier = container.read(audioRecorderProvider.notifier);
      
      // Démarrer un enregistrement d'abord
      mockAudioRepository.shouldStartSucceed = true;
      await notifier.startRecording();
      
      // S'assurer qu'il y a un état à réinitialiser
      expect(container.read(audioRecorderProvider).isRecording, isTrue);
      
      // Arrêter d'abord (requis avant reset)
      await notifier.stopRecording();
      
      // Maintenant reset
      notifier.reset();
      
      final state = container.read(audioRecorderProvider);
      expect(state.isRecording, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.lastRecordingPath, isNull);
      expect(state.errorMessage, isNull);
    });

    test('stream des secondes écoulées fonctionne', () async {
      final notifier = container.read(audioRecorderProvider.notifier);
      
      // Configuration du mock
      mockAudioRepository.shouldStartSucceed = true;
      
      // Écouter les changements d'état
      final stateChanges = <AudioRecorderState>[];
      final subscription = container.listen(
        audioRecorderProvider,
        (previous, next) {
          stateChanges.add(next);
        },
      );
      
      // Démarrer l'enregistrement
      await notifier.startRecording();
      
      // Attendre un peu pour que le mock génère des secondes
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Vérifier qu'il y a eu des changements d'état
      expect(stateChanges.isNotEmpty, isTrue);
      
      subscription.close();
    });

    group('Tests d\'erreurs', () {
      test('gère les erreurs d\'initialisation', () async {
        // Créer un nouveau container avec un mock qui échoue à l'initialisation
        final failingMockRepo = MockAudioRepository();
        failingMockRepo.shouldInitializeSucceed = false;
        
        final failingContainer = ProviderContainer(
          overrides: [
            audioRecorderProvider.overrideWith((ref) {
              return AudioRecorderNotifier(failingMockRepo);
            }),
          ],
        );
        
        // L'initialisation devrait échouer et l'état d'erreur devrait être mis à jour
        final state = failingContainer.read(audioRecorderProvider);
        expect(state.isInitialized, isFalse);
        
        failingContainer.dispose();
      });

      test('gère les erreurs de permissions', () async {
        final notifier = container.read(audioRecorderProvider.notifier);
        
        // Configuration du mock pour refuser les permissions
        mockAudioRepository.shouldRequestPermissionSucceed = false;
        
        final result = await notifier.startRecording();
        
        expect(result, isFalse);
        final state = container.read(audioRecorderProvider);
        expect(state.isRecording, isFalse);
      });
    });
  });
}

/// TODO: Tests additionnels à implémenter
/// 
/// 1. Tests d'intégration avec TranscriptionProvider :
///    - Vérifier que l'arrêt d'enregistrement déclenche automatiquement la transcription
///    - Tester la coordination entre les deux providers
/// 
/// 2. Tests de performance :
///    - Mesurer le temps de démarrage/arrêt d'enregistrement
///    - Vérifier qu'il n'y a pas de fuites mémoire lors de cycles multiples
/// 
/// 3. Tests de gestion d'état complexe :
///    - Enregistrements multiples successifs
///    - Interruptions système (appels entrants, etc.)
///    - Gestion de la rotation d'écran pendant l'enregistrement
/// 
/// 4. Tests de widgets avec providers :
///    - Utiliser ProviderScope.overrideWith dans les tests de widgets
///    - Vérifier que l'UI réagit correctement aux changements d'état
/// 
/// 5. Tests de persistence :
///    - Vérifier que les fichiers d'enregistrement sont bien créés
///    - Tester la récupération après crash d'application 