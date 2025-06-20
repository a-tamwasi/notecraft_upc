/// Interface abstraite pour les services de transcription
/// Permet de mocker facilement OpenAI ou d'autres services de transcription
abstract class TranscriptionRepository {
  /// Transcrit un fichier audio en utilisant l'IA
  /// [filePath] : chemin vers le fichier audio à transcrire
  /// Retourne le texte transcrit ou lance une exception
  Future<String> transcribeAudio(String filePath);
  
  /// Génère un titre pertinent et concis pour un texte donné
  /// [text] : le texte pour lequel générer un titre
  /// Retourne un titre court (5 mots maximum) ou lance une exception
  Future<String> generateTitle(String text);
  
  /// Améliore une transcription brute en utilisant l'IA
  Future<String> enhanceTranscription(String rawText);
  
  /// Libère les ressources (fermeture de connexions HTTP, etc.)
  void dispose();
} 