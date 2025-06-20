/// Interface abstraite pour les services de transcription audio uniquement
/// Séparé de la génération de titre pour permettre l'utilisation de différents providers
abstract class AudioTranscriptionRepository {
  /// Transcrit un fichier audio en utilisant l'IA
  /// [filePath] : chemin vers le fichier audio à transcrire
  /// Retourne le texte transcrit ou lance une exception
  Future<String> transcribeAudio(String filePath);
  
  /// Libère les ressources (fermeture de connexions HTTP, etc.)
  void dispose();
} 