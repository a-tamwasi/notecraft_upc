import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Classe d'exception personnalisée pour les erreurs liées à l'API OpenAI.
class OpenAIException implements Exception {
  final String message;
  OpenAIException(this.message);

  @override
  String toString() => 'OpenAIException: $message';
}

/// Un service optimisé pour la communication avec l'API d'OpenAI.
/// Inclut des optimisations pour réduire le temps de transcription.
class OpenAIService {
  /// L'endpoint de l'API Whisper pour les transcriptions.
  static const String _url = 'https://api.openai.com/v1/audio/transcriptions';
  
  /// Client HTTP réutilisable avec timeout optimisé
  static final http.Client _client = http.Client();

  /// Récupère la clé API depuis les variables d'environnement de manière sécurisée.
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

  /// Vérifie et optimise la taille du fichier avant envoi
  Future<File> _optimizeAudioFile(String filePath) async {
    final file = File(filePath);
    final fileSize = await file.length();
    
    // Si le fichier fait plus de 10MB, on pourrait le compresser
    // Pour l'instant, on retourne le fichier tel quel
    // TODO: Ajouter compression audio si nécessaire
    
    print('📁 Taille du fichier: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    return file;
  }

  /// Transcrit un fichier audio en utilisant l'API Whisper d'OpenAI avec optimisations.
  Future<String> transcrireAudio(String cheminFichier) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      print('🚀 Début de la transcription...');
      
      final apiKey = _getApiKey();
      final uri = Uri.parse(_url);
      
      // Optimisation du fichier
      final optimizedFile = await _optimizeAudioFile(cheminFichier);
      
      // Création de la requête avec headers optimisés
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $apiKey',
          'User-Agent': 'NoteCraft/1.0',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        });

      // Ajout du fichier avec lecture optimisée
      print('📤 Envoi du fichier...');
      final multipartFile = await http.MultipartFile.fromPath(
        'file', 
        optimizedFile.path,
        // Spécifier le type MIME pour éviter la détection automatique
        contentType: _getContentType(cheminFichier),
      );
      request.files.add(multipartFile);

      // Paramètres optimisés pour Whisper
      request.fields.addAll({
        'model': 'whisper-1',
        'response_format': 'json', // Plus rapide que verbose_json
        'language': 'fr', // Spécifier la langue pour accélérer
        'temperature': '0', // Déterministe, plus rapide
      });

      print('⏳ Envoi de la requête à OpenAI...');
      
      // Envoi sans timeout
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      print('⚡ Temps total: ${stopwatch.elapsedMilliseconds}ms');

      // Traitement optimisé de la réponse
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final transcription = responseData['text'] as String;
        
        print('✅ Transcription réussie (${transcription.length} caractères)');
        return transcription.trim();
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['error']?['message'] ?? 'Erreur inconnue';
        throw OpenAIException('Erreur API (${response.statusCode}): $errorMessage');
      }
      
    } on SocketException {
      throw OpenAIException('Erreur réseau. Vérifiez votre connexion internet.');
    } catch (e) {
      stopwatch.stop();
      print('❌ Erreur après ${stopwatch.elapsedMilliseconds}ms: $e');
      
      if (e is OpenAIException) {
        rethrow;
      }
      throw OpenAIException('Erreur inattendue: $e');
    }
  }

  /// Détermine le type MIME optimal selon l'extension
  MediaType? _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'm4a':
        return MediaType.parse('audio/mp4');
      case 'mp3':
        return MediaType.parse('audio/mpeg');
      case 'wav':
        return MediaType.parse('audio/wav');
      case 'webm':
        return MediaType.parse('audio/webm');
      default:
        return null; // Laisser HTTP détecter automatiquement
    }
  }

  /// Nettoie les ressources
  static void dispose() {
    _client.close();
  }
} 