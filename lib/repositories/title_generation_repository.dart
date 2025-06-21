
/// Interface abstraite pour les services de génération de titre uniquement
/// Séparé de la transcription pour permettre l'utilisation de différents providers
abstract class TitleGenerationRepository {
  /// Génère un titre pertinent et concis pour un texte donné
  /// [text] : le texte pour lequel générer un titre
  /// Retourne un titre court (5 mots maximum) ou lance une exception
  Future<String> generateTitle(String text);
  
  /// Libère les ressources (fermeture de connexions HTTP, etc.)
  void dispose();
}

/// Interface pour le service d'amélioration de texte.
abstract class TextEnhancementRepository {
  /// Améliore une transcription brute en utilisant un modèle de langage.
  Future<String> enhanceTranscription(String rawText);
}

// Combiner les interfaces pour le service OpenAI
abstract class OpenAIRepository implements TitleGenerationRepository, TextEnhancementRepository {} 