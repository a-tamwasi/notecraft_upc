import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/transcription_repository.dart';
import '../repositories/export_repository.dart';
import '../repositories/credit_repository.dart';
import '../repositories/audio_repository.dart';
import '../repositories/audio_recorder_repository_impl.dart';
import '../controllers/audio_recorder_controller.dart';
import '../services/openai_service.dart';
import '../services/export_service.dart';
import '../services/credit_service.dart';

/// Provider pour le repository de transcription (OpenAI)
/// 
/// TODO: Créer des tests d'intégration pour ce provider
/// - Test avec mock d'OpenAIService
/// - Test de gestion d'erreurs réseau
/// - Test de transcription avec différents formats audio
final transcriptionRepositoryProvider = Provider<TranscriptionRepository>((ref) {
  return OpenAIService();
});

/// Provider pour le repository d'export
/// 
/// TODO: Créer des tests d'intégration pour ce provider
/// - Test avec mock d'ExportService
/// - Test d'export vers différents formats
/// - Test de gestion d'erreurs de permissions
final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportService();
});

/// Provider pour le repository de crédits
/// 
/// TODO: Créer des tests d'intégration pour ce provider
/// - Test avec mock de CreditService
/// - Test de persistance des crédits
/// - Test de synchronisation entre instances
final creditRepositoryProvider = Provider<CreditRepository>((ref) {
  return creditService; // Instance globale existante
});

/// Provider pour le repository audio
/// 
/// TODO: Créer des tests d'intégration pour ce provider
/// - Test avec mock d'AudioRecorderController
/// - Test du cycle complet d'enregistrement
/// - Test de gestion des permissions microphone
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRecorderRepositoryImpl();
});

/// Provider pour exposer directement le contrôleur audio
/// Utilisé uniquement pour les ValueListenableBuilder qui ont besoin d'un accès direct
/// au ValueNotifier du contrôleur pour éviter les rebuilds inutiles
final audioRecorderControllerProvider = Provider<AudioRecorderController>((ref) {
  final repository = ref.watch(audioRepositoryProvider) as AudioRecorderRepositoryImpl;
  return repository.controller;
});

/// Provider pour nettoyer les ressources à la fin de l'application
/// 
/// TODO: Implémenter la logique de nettoyage globale
/// - Fermeture des connexions HTTP
/// - Libération des ressources audio
/// - Sauvegarde des données persistantes
final cleanupProvider = Provider<void>((ref) {
  ref.onDispose(() {
    // Nettoyage des ressources globales
    OpenAIService.closeHttpClient();
  });
}); 