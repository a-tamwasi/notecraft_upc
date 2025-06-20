import '../repositories/audio_transcription_repository.dart';
import '../repositories/title_generation_repository.dart';
import '../repositories/transcription_repository.dart';
import 'deepgram_service.dart';
import 'openai_service.dart';

/// Service hybride qui gère la transcription, la génération de titres et l'amélioration de texte.
/// 
/// Cette approche permet d'optimiser les performances :
/// - Deepgram : transcription rapide et précise SANS limite de taille + TOUTES langues
/// - OpenAI : génération de titres intelligents et contextuels
/// - AUCUN fallback : Deepgram est fiable pour tous types de fichiers
/// - Support multilingue : détection automatique de la langue
/// 
/// TODO: Écrire des tests unitaires pour HybridTranscriptionService
/// - Test de transcription avec Deepgram + génération titre avec OpenAI
/// - Test de gestion d'erreurs Deepgram sans fallback
/// - Test avec des fichiers de très grande taille (>100MB)
/// - Test de performance optimisée
class HybridTranscriptionService implements TranscriptionRepository, TextEnhancementRepository {
  final AudioTranscriptionRepository _audioTranscriptionRepository;
  final OpenAIRepository _openAIRepository;
  
  /// Constructeur avec injection de dépendances
  HybridTranscriptionService({
    AudioTranscriptionRepository? audioTranscriptionRepository,
    OpenAIRepository? openAIRepository,
  }) : _audioTranscriptionRepository = audioTranscriptionRepository ?? DeepgramService(),
        _openAIRepository = openAIRepository ?? OpenAIService();

  /// Transcrit un fichier audio en utilisant EXCLUSIVEMENT Deepgram
  @override
  Future<String> transcribeAudio(String filePath) async {
    print('🎯 Utilisation exclusive de Deepgram pour la transcription...');
    try {
      return await _audioTranscriptionRepository.transcribeAudio(filePath);
    } catch (e) {
      print('❌ Erreur Deepgram: $e');
      rethrow;
    }
  }

  /// Transcrit un fichier audio avec optimisation de vitesse MAXIMALE
  /// Utilise des paramètres optimisés pour réduire le temps de traitement
  Future<String> transcribeAudioFast(String filePath) async {
    print('🚀 Utilisation de Deepgram en mode ULTRA-RAPIDE...');
    try {
      if (_audioTranscriptionRepository is DeepgramService) {
        final deepgram = _audioTranscriptionRepository as DeepgramService;
        return await deepgram.transcribeAudioFast(filePath);
      } else {
        // Fallback sur la méthode normale si ce n'est pas DeepgramService
        return await _audioTranscriptionRepository.transcribeAudio(filePath);
      }
    } catch (e) {
      print('❌ Erreur Deepgram ultra-rapide: $e');
      rethrow;
    }
  }

  /// Génère un titre en utilisant OpenAI
  @override
  Future<String> generateTitle(String text) async {
    try {
      print('🧠 Utilisation d\'OpenAI pour la génération de titre...');
      return await _openAIRepository.generateTitle(text);
    } catch (e) {
      print('⚠️ Erreur génération titre OpenAI: $e');
      final now = DateTime.now();
      return 'Transcription du ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Améliore la transcription en utilisant OpenAI GPT-4o
  @override
  Future<String> enhanceTranscription(String rawText) async {
    print('✨ Appel de l\'amélioration de texte via le service hybride...');
    try {
      return await _openAIRepository.enhanceTranscription(rawText);
    } catch (e) {
      print('❌ Erreur lors de l\'amélioration du texte: $e');
      rethrow;
    }
  }

  /// Libère les ressources des deux services
  @override
  void dispose() {
    _audioTranscriptionRepository.dispose();
    _openAIRepository.dispose();
  }

  /// Méthode utilitaire pour obtenir des informations sur la configuration actuelle
  Map<String, String> getServiceInfo() {
    return {
      'transcription_provider': _audioTranscriptionRepository.runtimeType.toString(),
      'title_generation_provider': _openAIRepository.runtimeType.toString(),
      'architecture': 'hybrid',
    };
  }

  /// Méthode pour forcer l'utilisation d'OpenAI pour la transcription (pour les tests)
  static HybridTranscriptionService createWithOpenAITranscription() {
    final openAIService = OpenAIService();
    return HybridTranscriptionService(
      audioTranscriptionRepository: openAIService,
      openAIRepository: openAIService,
    );
  }

  /// Méthode pour forcer l'utilisation de Deepgram uniquement (sans génération de titre)
  static HybridTranscriptionService createWithDeepgramOnly() {
    return HybridTranscriptionService(
      audioTranscriptionRepository: DeepgramService(),
      openAIRepository: OpenAIService(), // Garder OpenAI pour les titres
    );
  }
} 