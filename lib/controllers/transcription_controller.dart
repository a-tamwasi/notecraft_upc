import 'package:flutter/foundation.dart';
// import 'package:notecraft_upc/data/database/database_service.dart'; // Import inutile
import 'package:notecraft_upc/data/repositories/note_repository.dart';
import 'package:notecraft_upc/services/openai_service.dart';
import '../models/note_model.dart';
import 'package:notecraft_upc/data/database/database_service.dart';

/// Contrôleur pour gérer la logique de transcription.
/// Fait le lien entre les vues, les services (API) et les repositories (BD).
class TranscriptionController extends ChangeNotifier {
  // --- Dépendances ---
  final OpenAIService _openAIService;
  final NoteRepository _noteRepository;

  // --- État ---
  List<Note> _transcriptions = [];
  Note? _transcriptionEnCours;
  bool _estEnChargement = false;
  String? _messageErreur;

  /// Constructeur du contrôleur.
  /// On instancie directement les dépendances ici pour simplifier.
  /// Dans une application plus grande, on utiliserait un injecteur de dépendances (comme GetIt ou Provider).
  TranscriptionController()
      : _openAIService = OpenAIService(),
        _noteRepository = NoteRepositoryImpl(DatabaseService.instance);

  // --- Getters (Accesseurs publics à l'état) ---
  List<Note> get transcriptions => List.unmodifiable(_transcriptions);
  Note? get transcriptionEnCours => _transcriptionEnCours;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;
  bool get aUneErreur => _messageErreur != null;
  
  // --- Méthodes Publiques (Actions de l'utilisateur) ---

  /// Charge toutes les notes depuis la base de données au démarrage.
  Future<void> chargerNotesInitiales() async {
    _definirEtatChargement(true);
    try {
      _transcriptions = await _noteRepository.getAllNotes();
    } catch (e) {
      _definirErreur("Erreur lors du chargement des notes : $e");
    } finally {
      _definirEtatChargement(false);
    }
  }

  /// TODO: Implémenter la logique d'enregistrement
  Future<void> demarrerEnregistrement() async {
    _definirEtatChargement(true);
    _effacerErreur();

    try {
      // TODO: Appeler le service d'enregistrement audio
      throw UnimplementedError('Service d\'enregistrement à implémenter');
    } catch (e) {
      _definirErreur('Erreur lors du démarrage de l\'enregistrement: $e');
    } finally {
      _definirEtatChargement(false);
    }
  }

  /// TODO: Implémenter la logique d'arrêt et transcription
  Future<void> arreterEnregistrementEtTranscrire(String cheminAudio) async {
    // Cette méthode peut partager la logique de transcription avec importerEtTranscrireFichier
    await transcrireEtSauvegarder(cheminAudio);
  }

  /// Importe un fichier audio, le transcrit via OpenAI, et sauvegarde le résultat.
  Future<void> importerEtTranscrireFichier(String cheminFichier) async {
    await transcrireEtSauvegarder(cheminFichier);
  }

  /// Logique de base pour la transcription et la sauvegarde.
  Future<void> transcrireEtSauvegarder(String cheminFichier) async {
    _definirEtatChargement(true);
    _effacerErreur();

    try {
      // 1. Appeler le service OpenAI pour la transcription
      final texteTranscrit = await _openAIService.transcrireAudio(cheminFichier);

      // 2. Créer un objet Note avec le résultat
      final nouvelleNote = Note(
        titre: _creerTitreDepuisContenu(texteTranscrit),
        contenu: texteTranscrit,
        dateCreation: DateTime.now(),
        cheminAudio: cheminFichier,
        langue: 'fr', // Pour l'instant, on met 'fr' par défaut
        duree: 0, // TODO: Obtenir la vraie durée
      );

      // 3. Sauvegarder la note dans la base de données via le repository
      final noteSauvegardee = await _noteRepository.addNote(nouvelleNote);

      // 4. Mettre à jour l'état local pour rafraîchir l'interface
      _ajouterNoteEnLocal(noteSauvegardee);

    } on OpenAIException catch (e) {
      // Gère spécifiquement les erreurs venant de notre service OpenAI
      _definirErreur(e.message);
    } catch (e) {
      // Gère toutes les autres erreurs potentielles
      _definirErreur('Une erreur inattendue est survenue: $e');
    } finally {
      _definirEtatChargement(false);
    }
  }


  /// Supprime une transcription de la base de données et de l'état local.
  Future<void> supprimerTranscription(int? id) async {
    if (id == null) return;
    _effacerErreur();
    try {
      await _noteRepository.deleteNote(id);
      _transcriptions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _definirErreur("Erreur lors de la suppression : $e");
    }
  }

  /// Efface toutes les transcriptions.
  void effacerToutesTranscriptions() {
    // TODO: Ajouter la logique de suppression dans la base de données si nécessaire
    _transcriptions.clear();
    _transcriptionEnCours = null;
    notifyListeners();
  }

  // --- Méthodes Privées (Gestion de l'état et utilitaires) ---

  void _definirEtatChargement(bool enChargement) {
    _estEnChargement = enChargement;
    notifyListeners();
  }

  void _definirErreur(String message) {
    _messageErreur = message;
    notifyListeners();
  }

  void _effacerErreur() {
    _messageErreur = null;
    // On notifie l'UI si elle doit retirer un message d'erreur
    notifyListeners();
  }

  void _ajouterNoteEnLocal(Note note) {
    _transcriptions.insert(0, note);
    _transcriptionEnCours = note;
    notifyListeners();
  }
  
  /// Crée un titre concis à partir des premiers mots du contenu.
  String _creerTitreDepuisContenu(String contenu) {
    if (contenu.isEmpty) return "Nouvelle note";
    var mots = contenu.split(' ');
    // Prend les 5 premiers mots ou moins si le texte est plus court.
    return mots.take(5).join(' ');
  }

  @override
  void dispose() {
    // TODO: Nettoyer les ressources (arrêter l'enregistrement si en cours, etc.)
    super.dispose();
  }
} 