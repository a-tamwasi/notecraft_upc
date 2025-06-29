import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';
import '../../data/database/database_service.dart';
import '../../models/note_model.dart';
import '../../notifiers/history_notifier.dart';
import '../../services/pdf_service.dart';
import 'dart:io';
import 'dart:convert';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA PAGE D'HISTORIQUE
// --- //

/// Affiche la liste des transcriptions passées de l'utilisateur.
///
/// Elle inclut des contrôles pour rechercher et trier les transcriptions.
class PageHistorique extends StatefulWidget {
  const PageHistorique({super.key});

  @override
  State<PageHistorique> createState() => _PageHistoriqueState();
}

class _PageHistoriqueState extends State<PageHistorique> {
  // Options de tri. La clé est la valeur, la valeur est le libellé.
  final Map<String, String> _optionsTri = {
    'date_desc': 'Trier par date',
    'titre_asc': 'Trier par titre',
    'duree_asc': 'Trier par durée',
  };
  // Valeur de tri actuellement sélectionnée.
  String _valeurTriSelectionnee = 'date_desc';
  late Future<List<Note>> _notesFuture;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  // Nouvel état pour gérer l'affichage des versions dans les dialogues
  final Map<int?, bool> _showEnhancedVersion = {};

  @override
  void initState() {
    super.initState();
    _refreshNotes();
    historyNotifier.addListener(_refreshNotes);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void deactivate() {
    // Ferme le clavier quand la page devient inactive (navigation vers autre onglet)
    _searchFocusNode.unfocus();
    super.deactivate();
  }

  @override
  void dispose() {
    historyNotifier.removeListener(_refreshNotes);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Déclenche un rebuild pour mettre à jour le bouton clear du champ de recherche
    });
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = DatabaseService.instance.readAll(
        searchQuery: _searchController.text,
        sortOrder: _valeurTriSelectionnee,
      );
    });
  }

  Future<void> _supprimerNote(int id) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette note ? L\'action est irréversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await DatabaseService.instance.delete(id);
        showSuccess(context, 'Note supprimée avec succès.');
        _refreshNotes(); // Rafraîchir la liste
      } catch (e) {
        showError(context, 'Erreur lors de la suppression: $e');
      }
    }
  }

  Future<void> _exporterTxt(Note note) async {
    if (note.contenu.isEmpty) {
      showInfo(context, 'Cette note est vide.');
      return;
    }

    try {
      final timestamp = note.dateCreation;
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_${note.id}_$formattedDate.txt';

      final content = '''NoteCraft - Transcription Audio
Titre: ${note.titre}
Date de création: ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(timestamp)}
Durée de l'audio: ${note.duree} secondes
Nombre de caractères: ${note.contenu.length}
Nombre de mots: ${note.contenu.split(' ').where((word) => word.isNotEmpty).length}

=====================================
CONTENU DE LA TRANSCRIPTION
=====================================

${note.contenu}

=====================================
Généré par NoteCraft App
=====================================''';
      
      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        ext: 'txt',
        mimeType: MimeType.text,
      );

      Navigator.of(context).pop();

      if (filePath != null) {
        showSuccess(context, '✅ Fichier TXT exporté avec succès !');
      } else {
        showInfo(context, 'Exportation annulée par l\'utilisateur');
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      showError(context, '❌ Erreur lors de l\'exportation TXT: $e');
    }
  }

  Future<void> _exporterPdf(Note note) async {
    if (note.contenu.isEmpty) {
      showInfo(context, 'Cette note est vide.');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Génération du PDF...'),
            ],
          ),
        ),
      );

      final timestamp = note.dateCreation;
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_${note.id}_$formattedDate.pdf';

      final String tempFilePath = await PdfService.exporterTranscriptionPdf(
        transcription: note.contenu,
        fileName: fileName,
      );

      final File tempFile = File(tempFilePath);
      final Uint8List pdfBytes = await tempFile.readAsBytes();

      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      Navigator.of(context).pop();

      if (filePath != null) {
        showSuccess(context, '✅ PDF exporté avec succès !');
      } else {
        showInfo(context, 'Exportation annulée par l\'utilisateur');
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      showError(context, '❌ Erreur lors de l\'exportation PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour la zone des contrôles
      body: GestureDetector(
        onTap: () {
          // Ferme le clavier et retire le focus du champ de recherche
          _searchFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // --- Section des contrôles (fixe) ---
            Padding(
              padding: const EdgeInsets.all(DimensionsApplication.paddingL),
              child: _construireControlesFiltre(),
            ),
            // --- Section de la liste (scrollable) ---
            Expanded(
              child: Container(
                color: CouleursApplication.fondPrincipal, // Fond pour la liste
                child: FutureBuilder<List<Note>>(
                  future: _notesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucune transcription dans l\'historique.'));
                    } else {
                      final notes = snapshot.data!;
                      final searchQuery = _searchController.text;
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: DimensionsApplication.paddingL,
                          right: DimensionsApplication.paddingL,
                          bottom: 60, // Padding en bas pour éviter que le contenu soit caché par la bottom navigation bar
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return _construireCarteTranscription(note, searchQuery);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une carte de transcription unique à partir d'un objet Note
  Widget _construireCarteTranscription(Note note, String searchQuery) {
    final formattedDate = DateFormat('d MMMM y, HH:mm', 'fr_FR').format(note.dateCreation);
    final formattedDuration =
        '${(note.duree ~/ 60).toString().padLeft(2, '0')}:${(note.duree % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: DimensionsApplication.margeMoyenne),
      child: GestureDetector(
        onTap: () => _afficherApercuTranscription(context, note),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DimensionsApplication.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- En-tête avec titre, langue et menu ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre avec badge langue
                          Row(
                            children: [
                              Flexible(
                                child: _highlightOccurrences(
                                  note.titre,
                                  searchQuery,
                                  StylesTexte.titreSection.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: DimensionsApplication.paddingS),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                                ),
                                child: Text(
                                  note.langue,
                                  style: StylesTexte.corpsPetit.copyWith(
                                    color: Colors.grey.shade700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DimensionsApplication.paddingS),
                          // Aperçu du contenu
                          _highlightOccurrences(
                            note.contenu,
                            searchQuery,
                            StylesTexte.corps.copyWith(
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    // Menu d'actions
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _supprimerNote(note.id!);
                        } else if (value == 'export_txt') {
                          _exporterTxt(note);
                        } else if (value == 'export_pdf') {
                          _exporterPdf(note);
                        }
                      },
                      color: Colors.white.withOpacity(0.9), // Fond semi-transparent
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'export_pdf',
                          child: ListTile(
                            leading: Icon(Iconsax.document_download),
                            title: Text('Exporter en PDF'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'export_txt',
                          child: ListTile(
                            leading: Icon(Iconsax.document_text),
                            title: Text('Exporter en TXT'),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Iconsax.trash, color: Theme.of(context).colorScheme.error),
                            title: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: DimensionsApplication.paddingM),
                // --- Pied avec date et durée ---
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: StylesTexte.corpsPetit.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDuration,
                      style: StylesTexte.corpsPetit.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Met en évidence les occurrences d'un texte de recherche dans un texte donné.
  Widget _highlightOccurrences(String text, String query, TextStyle style, {int? maxLines}) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final List<TextSpan> spans = [];
    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();
    int lastIndex = 0;

    while (lastIndex < text.length) {
      final int index = lowerCaseText.indexOf(lowerCaseQuery, lastIndex);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(lastIndex), style: style));
        break;
      }

      if (index > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, index), style: style));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: CouleursApplication.primaire.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ));

      lastIndex = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construit la section contenant la barre de recherche et le menu de tri.
  Widget _construireControlesFiltre() {
    return Column(
      children: [
        // --- Barre de recherche ---
        TextFormField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (value) {
            // Ferme le clavier quand l'utilisateur appuie sur "OK" ou "Rechercher"
            _searchFocusNode.unfocus();
          },
          onTapOutside: (event) {
            // Ferme le clavier quand l'utilisateur tape en dehors du champ
            _searchFocusNode.unfocus();
          },
          decoration: InputDecoration(
            hintText: 'Rechercher une transcription...',
            hintStyle: StylesTexte.corps.copyWith(color: CouleursApplication.texteSecondaire),
            prefixIcon: const Icon(Iconsax.search_normal_1, color: CouleursApplication.texteSecondaire),
            // Bouton pour effacer le texte si il y en a un
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: CouleursApplication.texteSecondaire),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
              borderSide: const BorderSide(color: CouleursApplication.primaire, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: DimensionsApplication.paddingM),
          ),
          style: StylesTexte.corps.copyWith(color: CouleursApplication.textePrincipal),
        ),
        const SizedBox(height: DimensionsApplication.margeMoyenne),
        // --- Menu déroulant pour le tri (version personnalisée avec PopupMenuButton) ---
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: DimensionsApplication.paddingL, vertical: 14.0),
          ),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero, // Supprime le padding interne pour un alignement parfait
            position: PopupMenuPosition.under,
            offset: const Offset(-DimensionsApplication.paddingL, 8), // Décale le menu vers la gauche
            onSelected: (String nouvelleValeur) {
              setState(() {
                _valeurTriSelectionnee = nouvelleValeur;
              });
              _refreshNotes();
            },
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
            ),
            itemBuilder: (BuildContext context) {
              return _optionsTri.entries.map((entry) {
                final valeur = entry.key;
                final libelle = entry.value;
                final estSelectionne = _valeurTriSelectionnee == valeur;
                return PopupMenuItem<String>(
                  value: valeur,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: estSelectionne
                          ? CouleursApplication.primaire.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(DimensionsApplication.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          estSelectionne ? Icons.check : null,
                          color: CouleursApplication.primaire,
                          size: 20,
                        ),
                        const SizedBox(width: DimensionsApplication.paddingM),
                        Text(libelle),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _optionsTri[_valeurTriSelectionnee]!,
                  style: StylesTexte.corps
                      .copyWith(color: CouleursApplication.textePrincipal),
                ),
                const Icon(Iconsax.arrow_down_1,
                    color: CouleursApplication.texteSecondaire),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Affiche une boîte de dialogue modale avec les détails complets de la transcription.
  void _afficherApercuTranscription(BuildContext context, Note note) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _TranscriptionDetailDialog(
          note: note,
          onUpdate: () => _refreshNotes(), // Rafraîchit la liste après modification
        );
      },
    );
  }

  /// Bascule entre la version brute et améliorée pour une note donnée
  void _toggleVersionForNote(int? noteId) {
    setState(() {
      _showEnhancedVersion[noteId] = !(_showEnhancedVersion[noteId] ?? false);
    });
  }

  /// Récupère le contenu à afficher selon le mode sélectionné
  String _getDisplayContent(Note note) {
    final showEnhanced = _showEnhancedVersion[note.id] ?? false;
    return note.getContent(enhanced: showEnhanced);
  }
}

/// Un widget avec état pour la boîte de dialogue des détails de la transcription,
/// permettant l'édition du contenu.
class _TranscriptionDetailDialog extends StatefulWidget {
  final Note note;
  final VoidCallback onUpdate;

  const _TranscriptionDetailDialog({required this.note, required this.onUpdate});

  @override
  State<_TranscriptionDetailDialog> createState() => _TranscriptionDetailDialogState();
}

class _TranscriptionDetailDialogState extends State<_TranscriptionDetailDialog> {
  late final TextEditingController _textController;
  bool _isModified = false;
  bool _showEnhanced = false; // État pour basculer entre les versions

  @override
  void initState() {
    super.initState();
    // Initialiser avec la version brute par défaut
    _textController = TextEditingController(text: widget.note.contenu);
    
    // Écoute les changements pour afficher ou masquer le bouton de sauvegarde
    _textController.addListener(() {
      final originalText = _showEnhanced ? (widget.note.contenuAmeliore ?? '') : widget.note.contenu;
      final hasChanged = _textController.text != originalText;
      if (hasChanged != _isModified) {
        setState(() {
          _isModified = hasChanged;
        });
      }
    });
  }

  /// Bascule entre les versions et met à jour le contrôleur
  void _toggleVersion() {
    setState(() {
      _showEnhanced = !_showEnhanced;
      final newText = _showEnhanced ? (widget.note.contenuAmeliore ?? '') : widget.note.contenu;
      _textController.text = newText;
      _isModified = false; // Reset car on change de version
    });
  }

  /// Sauvegarde la version actuellement affichée
  Future<void> _saveCurrentVersion() async {
    final updatedNote = _showEnhanced 
      ? widget.note.copy(contenuAmeliore: _textController.text)
      : widget.note.copy(contenu: _textController.text);
    
    await DatabaseService.instance.update(updatedNote);
    widget.onUpdate(); // Notifier le parent pour rafraîchir
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DimensionsApplication.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et bouton de fermeture
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.note.titre,
                        style: StylesTexte.titrePrincipal.copyWith(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: DimensionsApplication.margeMoyenne),
                
                // Métadonnées
                Row(
                  children: [
                    Icon(Iconsax.calendar_1, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(DateFormat('d MMM y, HH:mm', 'fr_FR').format(widget.note.dateCreation), style: StylesTexte.corpsPetit),
                    const SizedBox(width: 16),
                    Icon(Iconsax.clock, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${(widget.note.duree ~/ 60).toString().padLeft(2, '0')}:${(widget.note.duree % 60).toString().padLeft(2, '0')}', style: StylesTexte.corpsPetit),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                      ),
                      child: Text(
                        widget.note.langue,
                        style: StylesTexte.corpsPetit.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Toggle pour basculer entre les versions (si version améliorée disponible)
                if (widget.note.hasEnhancedVersion) ...[
                  const SizedBox(height: DimensionsApplication.paddingM),
                  Center(
                    child: ToggleButtons(
                      isSelected: [!_showEnhanced, _showEnhanced],
                      onPressed: (index) => _toggleVersion(),
                      borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Version brute'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Version améliorée ✨'),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const Divider(height: DimensionsApplication.margeGrande),
                
                // Contenu de la transcription (éditable)
                Flexible(
                  child: SingleChildScrollView(
                    child: TextFormField(
                      controller: _textController,
                      maxLines: null,
                      style: StylesTexte.corps.copyWith(height: 1.5, fontSize: 15),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DimensionsApplication.margeMoyenne),
                
                // Actions (bouton de sauvegarde conditionnel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isModified)
                      TextButton(
                        onPressed: () async {
                          await _saveCurrentVersion();
                          showSuccess(context, 'Modification sauvegardée !');
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sauvegarder'),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
} 