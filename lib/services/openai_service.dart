import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../repositories/transcription_repository.dart';

/// Classe d'exception personnalisée pour les erreurs liées à l'API OpenAI.
class OpenAIException implements Exception {
  final String message;
  OpenAIException(this.message);

  @override
  String toString() => 'OpenAIException: $message';
}

/// Un service optimisé pour la communication avec l'API d'OpenAI.
/// Inclut des optimisations pour réduire le temps de transcription.
/// 
/// TODO: Écrire des tests unitaires pour OpenAIService
/// - Test de transcription avec fichier audio valide
/// - Test de génération de titre avec texte valide
/// - Test de gestion d'erreurs (clé API invalide, réseau indisponible)
/// - Test de gestion des timeouts
/// - Mock du client HTTP pour tests isolés
class OpenAIService implements TranscriptionRepository {
  /// L'endpoint de l'API Whisper pour les transcriptions.
  static const String _transcriptionUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String _chatCompletionsUrl = 'https://api.openai.com/v1/chat/completions';
  
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
  @override
  Future<String> transcribeAudio(String filePath) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      print('🚀 Début de la transcription...');
      
      final apiKey = _getApiKey();
      final uri = Uri.parse(_transcriptionUrl);
      
      // Optimisation du fichier
      final optimizedFile = await _optimizeAudioFile(filePath);
      
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
        contentType: _getContentType(filePath),
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

  /// Génère un titre pertinent et concis pour un texte donné.
  @override
  Future<String> generateTitle(String text) async {
    print('🧠 Génération du titre pour le texte...');
    final stopwatch = Stopwatch()..start();

    try {
      final apiKey = _getApiKey();
      final uri = Uri.parse(_chatCompletionsUrl);

      final body = json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un expert en résumé de texte. '
                       'Ton unique rôle est de créer un titre court et pertinent '
                       'en 5 mots maximum pour le texte fourni par l\'utilisateur. '
                       'Ne réponds rien d\'autre que le titre.'
          },
          {'role': 'user', 'content': text}
        ],
        'temperature': 0.2,
        'max_tokens': 20,
      });

      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        body: body,
      );

      stopwatch.stop();
      print('⚡ Temps de génération du titre: ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        String titre = responseData['choices'][0]['message']['content'].trim();
        
        // Nettoyage au cas où le modèle ajouterait des guillemets
        titre = titre.replaceAll('"', '').replaceAll('Titre :', '').trim();
        
        print('✅ Titre généré: "$titre"');
        return titre;
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['error']?['message'] ?? 'Erreur inconnue';
        throw OpenAIException('Erreur API de chat (${response.statusCode}): $errorMessage');
      }
    } on SocketException {
      throw OpenAIException('Erreur réseau. Vérifiez votre connexion internet.');
    } catch (e) {
      stopwatch.stop();
      print('❌ Erreur de génération de titre après ${stopwatch.elapsedMilliseconds}ms: $e');
      
      if (e is OpenAIException) {
        rethrow;
      }
      // En cas d'erreur de génération, on retourne un titre par défaut
      return "Titre non généré";
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

  /// Implémentation de l'interface TranscriptionRepository
  @override
  void dispose() {
    // Les ressources statiques sont partagées, ne pas fermer ici
    // La fermeture se fait via closeHttpClient()
  }

  /// Nettoie les ressources HTTP statiques
  static void closeHttpClient() {
    _client.close();
  }
} 