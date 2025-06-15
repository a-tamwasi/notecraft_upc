import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Classe d'exception personnalisée pour les erreurs liées à l'API OpenAI.
class OpenAIException implements Exception {
  final String message;
  OpenAIException(this.message);

  @override
  String toString() => 'OpenAIException: $message';
}

/// Un service dédié à la communication avec l'API d'OpenAI.
/// Il encapsule toute la logique réseau pour la transcription audio.
class OpenAIService {
  /// L'endpoint de l'API Whisper pour les transcriptions.
  static const String _url = 'https://api.openai.com/v1/audio/transcriptions';

  /// Récupère la clé API depuis les variables d'environnement de manière sécurisée.
  /// Lance une `OpenAIException` si la clé n'est pas trouvée.
  String _getApiKey() {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'VOTRE_NOUVELLE_CLE_API_ICI') {
      throw OpenAIException(
        'Clé API OpenAI non trouvée. '
        'Assurez-vous d\'avoir créé un fichier .env à la racine '
        'et d\'y avoir ajouté votre clé : OPENAI_API_KEY=VOTRE_CLE',
      );
    }
    return apiKey;
  }

  /// Transcrit un fichier audio en utilisant l'API Whisper d'OpenAI.
  ///
  /// Prend en paramètre le [cheminFichier] du fichier audio à transcrire.
  /// Retourne le texte transcrit sous forme de `String`.
  /// Lance une `OpenAIException` en cas d'erreur de communication ou de réponse de l'API.
  Future<String> transcrireAudio(String cheminFichier) async {
    try {
      final apiKey = _getApiKey();
      final uri = Uri.parse(_url);
      
      // Crée une requête `multipart`. Ce type de requête est nécessaire
      // pour envoyer des fichiers et des données textuelles en même temps.
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $apiKey';

      // Ajoute le fichier audio à la requête.
      // 'file' est le nom du champ attendu par l'API Whisper.
      final file = await http.MultipartFile.fromPath('file', cheminFichier);
      request.files.add(file);

      // Ajoute le nom du modèle à utiliser.
      // 'model' est le nom du champ attendu par l'API.
      request.fields['model'] = 'whisper-1';

      // Envoie la requête et attend la réponse.
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Décode la réponse JSON.
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      // Vérifie si la requête a réussi (code de statut 200).
      if (response.statusCode == 200) {
        // Si oui, retourne le texte transcrit.
        return responseData['text'];
      } else {
        // Sinon, lance une exception avec le message d'erreur de l'API.
        final errorMessage = responseData['error']?['message'] ?? 'Erreur inconnue';
        throw OpenAIException('Erreur de l\'API (code ${response.statusCode}): $errorMessage');
      }
    } on SocketException {
      // Gère les erreurs de connexion réseau.
      throw OpenAIException('Erreur de réseau. Vérifiez votre connexion internet.');
    } catch (e) {
      // Propage les exceptions déjà typées ou en crée une nouvelle.
      if (e is OpenAIException) {
        rethrow;
      }
      throw OpenAIException('Une erreur inattendue est survenue: $e');
    }
  }
} 