import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../repositories/audio_transcription_repository.dart';

/// Classe d'exception personnalisée pour les erreurs liées à l'API Deepgram.
class DeepgramException implements Exception {
  final String message;
  DeepgramException(this.message);

  @override
  String toString() => 'DeepgramException: $message';
}

/// Service optimisé pour la transcription audio avec l'API Deepgram.
/// Utilise l'API REST de Deepgram pour transcrire des fichiers audio.
/// 
/// Avantages vs OpenAI:
/// - Pas de limite de 25MB pour les fichiers audio
/// - Transcription plus rapide 
/// - Détection automatique de TOUTES les langues
/// - Support de formats audio plus larges
/// - Smart formatting multilingue
/// 
/// TODO: Écrire des tests unitaires pour DeepgramService
/// - Test de transcription avec fichier audio valide
/// - Test de gestion d'erreurs (clé API invalide, réseau indisponible)
/// - Test de gestion des timeouts
/// - Test avec différents formats audio (m4a, mp3, wav, webm)
/// - Mock du client HTTP pour tests isolés
class DeepgramService implements AudioTranscriptionRepository {
  /// L'endpoint de l'API Deepgram pour les transcriptions.
  static const String _transcriptionUrl = 'https://api.deepgram.com/v1/listen';
  
  /// Client HTTP réutilisable avec timeout optimisé pour les longs audios
  static final http.Client _client = http.Client();

  /// Récupère la clé API Deepgram depuis les variables d'environnement de manière sécurisée.
  String _getApiKey() {
    final apiKey = dotenv.env['DEEPGRAM_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'VOTRE_CLE_DEEPGRAM_ICI') {
      throw DeepgramException(
        'Clé API Deepgram non trouvée. '
        'Assurez-vous d\'avoir créé un fichier .env à la racine '
        'et d\'y avoir ajouté votre clé : DEEPGRAM_API_KEY=VOTRE_CLE',
      );
    }
    return apiKey;
  }

  /// Vérifie la taille du fichier audio avant envoi
  Future<File> _checkAudioFile(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw DeepgramException('Le fichier audio n\'existe pas: $filePath');
    }
    
    final fileSize = await file.length();
    final extension = filePath.toLowerCase().split('.').last;
    
    print('📁 Taille du fichier: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    print('📄 Extension détectée: .$extension');
    print('🎵 Type MIME: ${_getContentType(filePath)?.toString() ?? 'auto-détecté'}');
    
    // Vérifier que le fichier n'est pas vide
    if (fileSize == 0) {
      throw DeepgramException('Le fichier audio est vide (0 bytes)');
    }
    
    // Vérifier les formats supportés par Deepgram
    const supportedFormats = ['m4a', 'mp3', 'wav', 'webm', 'ogg', 'flac', 'mp4', 'aac', 'aiff', 'au', 'dss', 'gsm', 'opus', 'raw', 'sphere', 'vox', 'wma'];
    if (!supportedFormats.contains(extension)) {
      print('⚠️ Format .$extension pas officiellement supporté, tentative quand même...');
    } else {
      print('✅ Format .$extension supporté par Deepgram');
    }
    
    print('✅ Fichier validé pour Deepgram');
    return file;
  }

  /// Transcrit un fichier audio en utilisant l'API REST Deepgram avec optimisations de vitesse.
  Future<String> transcribeAudio(String filePath) async {
    // Utilisation du modèle "nova-2" qui est plus fiable pour les transcriptions complètes
    // et ajout de paramètres pour s'assurer d'avoir le texte complet
    // Documentation: https://developers.deepgram.com/docs/pre-recorded-audio
    return await _transcribeWithConfig(filePath, {
      'model': 'nova-2',           // Modèle plus fiable que whisper-large
      'detect_language': 'true',
      'smart_format': 'true',
      'punctuate': 'true',
      'filler_words': 'false',     // Éviter la perte de contenu
      'utterances': 'false',       // Simplifier pour éviter les coupures
      'paragraphs': 'true',        // Garder pour un bon formatage
      'diarize': 'false',          // Éviter la complexité non nécessaire
    });
  }

  /// Transcrit un fichier audio avec des paramètres optimisés pour la vitesse MAXIMALE
  /// Utilise les paramètres les plus rapides possibles, au détriment de certaines fonctionnalités
  Future<String> transcribeAudioFast(String filePath) async {
    return await _transcribeWithConfig(filePath, {
      'model': 'nova-2',           // Modèle le plus rapide
      'language': 'fr',            // Langue fixe au lieu de détection auto (plus rapide)
      'punctuate': 'false',        // Désactiver la ponctuation pour plus de vitesse
      'filler_words': 'false',     // Pas de mots de remplissage
      'utterances': 'false',       // Pas de métadonnées
      'paragraphs': 'false',       // Pas de formatage avancé
      'diarize': 'false',          // Pas de séparation des locuteurs
      'smart_format': 'false',     // Pas de formatage intelligent
      'profanity_filter': 'false', // Pas de filtre de grossièretés
    });
  }

  /// Méthode interne pour transcrire avec une configuration spécifique
  Future<String> _transcribeWithConfig(String filePath, Map<String, String> queryParams) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      print('🚀 Début de la transcription Deepgram...');
      
      final apiKey = _getApiKey();
      final audioFile = await _checkAudioFile(filePath);
      final uri = Uri.parse(_transcriptionUrl).replace(queryParameters: queryParams);
      
      print('🔗 URL Deepgram: ${uri.toString()}');
      print('📋 Configuration: ${queryParams.toString()}');

      // Création d'une requête standard, PAS multipart
      final request = http.Request('POST', uri);

      // Définition des headers
      request.headers.addAll({
        'Authorization': 'Token $apiKey',
        'User-Agent': 'NoteCraft/1.0 Flutter/Deepgram',
        'Accept': 'application/json',
        'Content-Type': _getContentType(filePath)?.toString() ?? 'application/octet-stream',
      });

      // Ajout du corps de la requête avec les bytes du fichier
      print('📤 Lecture et envoi des bytes du fichier...');
      request.bodyBytes = await audioFile.readAsBytes();
      print('📊 Bytes lus et prêts à envoyer: ${request.bodyBytes.length}');
      
      // Envoi de la requête avec timeout étendu pour les longs audios
      print('⏳ Envoi à Deepgram avec timeout de 5 minutes...');
      final streamedResponse = await _client.send(request).timeout(
        const Duration(minutes: 9), // Timeout généreux pour les longs audios
        onTimeout: () {
          throw DeepgramException('Timeout de transcription (5 minutes). L\'audio est peut-être trop long.');
        },
      );
      
      print('📥 Réception de la réponse de Deepgram...');
      final response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(minutes: 2), // Timeout pour la lecture de la réponse
        onTimeout: () {
          throw DeepgramException('Timeout lors de la lecture de la réponse Deepgram.');
        },
      );

      stopwatch.stop();
      print('⚡ Temps total Deepgram: ${stopwatch.elapsedMilliseconds}ms');

      // Traitement de la réponse
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        final results = responseData['results'] as Map<String, dynamic>?;
        final channels = results?['channels'] as List<dynamic>?;
        if (channels == null || channels.isEmpty) {
          throw DeepgramException('Réponse invalide: structure de canaux manquante');
        }
        
        final firstChannel = channels[0] as Map<String, dynamic>;
        final alternatives = firstChannel['alternatives'] as List<dynamic>?;
        if (alternatives == null || alternatives.isEmpty) {
          throw DeepgramException('Réponse invalide: pas d\'alternatives de transcription');
        }
        
        final firstAlternative = alternatives[0] as Map<String, dynamic>;

        // Diagnostiquer la qualité de la réponse Deepgram
        print('🔍 DIAGNOSTIC DEEPGRAM:');
        print('   - Channels disponibles: ${channels.length}');
        print('   - Alternatives disponibles: ${alternatives.length}');
        
        // Analyser la structure complète pour diagnostiquer les problèmes
        final metadata = results?['metadata'] as Map<String, dynamic>?;
        if (metadata != null) {
          final duration = metadata['duration'] as double?;
          final channels_meta = metadata['channels'] as int?;
          print('   - Durée détectée: ${duration?.toStringAsFixed(2)}s');
          print('   - Canaux audio: $channels_meta');
        }

        // Prioriser la transcription formatée avec paragraphes pour un affichage propre
        final paragraphs = firstAlternative['paragraphs'] as Map<String, dynamic>?;
        if (paragraphs != null && paragraphs['transcript'] is String) {
          final formattedTranscript = paragraphs['transcript'] as String;
          if (formattedTranscript.trim().isNotEmpty) {
            print('✅ Transcription avec paragraphes extraite (${formattedTranscript.length} caractères)');
            print('🎯 Premiers 100 caractères: "${formattedTranscript.substring(0, formattedTranscript.length < 100 ? formattedTranscript.length : 100)}..."');
            print('🎯 Derniers 100 caractères: "...${formattedTranscript.substring(formattedTranscript.length < 100 ? 0 : formattedTranscript.length - 100)}"');
            return formattedTranscript.trim();
          }
        }

        // Fallback sur la transcription simple si les paragraphes ne sont pas disponibles
        final transcription = firstAlternative['transcript'] as String?;
        if (transcription != null && transcription.trim().isNotEmpty) {
          print('✅ Transcription simple extraite (${transcription.length} caractères)');
          print('🎯 Premiers 100 caractères: "${transcription.substring(0, transcription.length < 100 ? transcription.length : 100)}..."');
          print('🎯 Derniers 100 caractères: "...${transcription.substring(transcription.length < 100 ? 0 : transcription.length - 100)}"');
          return transcription.trim();
        }

        print('⚠️ Transcription vide reçue de Deepgram');
        print('🔍 Structure de la réponse: ${firstAlternative.keys.toList()}');
        return 'Aucun contenu audio détecté.';
        
      } else {
        // Gestion des erreurs Deepgram
        String errorMessage = 'Erreur Deepgram inconnue';
        try {
          final responseData = json.decode(response.body);
          errorMessage = responseData['err_msg'] ?? responseData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }
        throw DeepgramException('Erreur API Deepgram (${response.statusCode}): $errorMessage');
      }
      
    } on SocketException {
      throw DeepgramException('Erreur réseau. Vérifiez votre connexion internet.');
    } catch (e) {
      stopwatch.stop();
      print('❌ Erreur Deepgram après ${stopwatch.elapsedMilliseconds}ms: $e');
      
      if (e is DeepgramException) {
        rethrow;
      }
      throw DeepgramException('Erreur inattendue: $e');
    }
  }

  /// Détermine l'encodage audio selon l'extension du fichier
  String _getAudioEncoding(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'm4a':
      case 'mp4':
        return 'mp4';
      case 'mp3':
        return 'mp3';
      case 'wav':
        return 'wav';
      case 'webm':
        return 'webm';
      case 'ogg':
        return 'ogg';
      case 'flac':
        return 'flac';
      default:
        return 'auto'; // Laisser Deepgram détecter automatiquement
    }
  }

  /// Détermine le type MIME optimal selon l'extension
  MediaType? _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'm4a':
      case 'mp4':
        return MediaType.parse('audio/mp4');
      case 'mp3':
        return MediaType.parse('audio/mpeg');
      case 'wav':
        return MediaType.parse('audio/wav');
      case 'webm':
        return MediaType.parse('audio/webm');
      case 'ogg':
        return MediaType.parse('audio/ogg');
      case 'flac':
        return MediaType.parse('audio/flac');
      case 'aac':
        return MediaType.parse('audio/aac');
      case 'aiff':
      case 'aif':
        return MediaType.parse('audio/aiff');
      case 'opus':
        return MediaType.parse('audio/opus');
      case 'wma':
        return MediaType.parse('audio/x-ms-wma');
      case 'au':
        return MediaType.parse('audio/basic');
      default:
        // Pour les formats non reconnus, utiliser application/octet-stream
        // Deepgram peut souvent détecter automatiquement le format
        return MediaType.parse('application/octet-stream');
    }
  }

  /// Libère les ressources
  void dispose() {
    // Les ressources statiques sont partagées, ne pas fermer ici
    // La fermeture se fait via closeHttpClient()
  }

  /// Nettoie les ressources HTTP statiques
  static void closeHttpClient() {
    _client.close();
  }
} 