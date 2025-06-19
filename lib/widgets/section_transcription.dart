import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Widget pour afficher la section de transcription
/// 
/// Contient l'interface d'édition de la transcription avec un menu d'actions
/// pour sauvegarder, exporter en PDF/TXT et supprimer le contenu.
class SectionTranscription extends StatelessWidget {
  /// Contrôleur pour le champ de texte de transcription
  final TextEditingController controleurTranscription;
  
  /// GlobalKey pour faire défiler vers cette section
  final GlobalKey cle;
  
  /// Callback appelé lors de l'export en PDF
  final Future<void> Function() onExporterPdf;
  
  /// Callback appelé lors de l'export en TXT
  final Future<void> Function() onExporterTxt;
  
  /// Callback appelé lors de la sauvegarde
  final VoidCallback onSauvegarder;
  
  /// Callback appelé lors de la suppression
  final VoidCallback onSupprimer;

  const SectionTranscription({
    Key? key,
    required this.controleurTranscription,
    required this.cle,
    required this.onExporterPdf,
    required this.onExporterTxt,
    required this.onSauvegarder,
    required this.onSupprimer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: cle,
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construireEnTete(),
            const SizedBox(height: DimensionsApplication.margeSection),
            _construireChampTranscription(),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête avec titre et menu d'actions
  Widget _construireEnTete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _construireTitre(),
        _construireMenuActions(),
      ],
    );
  }

  /// Construit le titre de la section avec icône
  Widget _construireTitre() {
    return Row(
      children: [
        Icon(
          Icons.text_snippet,
          color: CouleursApplication.primaire,
          size: DimensionsApplication.iconeL,
        ),
        const SizedBox(width: DimensionsApplication.paddingS),
        Text(
          'Transcription',
          style: StylesTexte.titreSection,
        ),
      ],
    );
  }

  /// Construit le menu d'actions avec PopupMenuButton
  Widget _construireMenuActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: CouleursApplication.primaire,
        size: 24,
      ),
      tooltip: 'Options',
      color: Colors.white.withOpacity(0.95),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: _gererSelectionMenu,
      itemBuilder: (BuildContext context) => [
        _construireElementMenuSauvegarder(),
        _construireElementMenuExporterPdf(),
        _construireElementMenuExporterTxt(),
        _construireElementMenuSupprimer(),
      ],
    );
  }

  /// Construit l'élément de menu "Sauvegarder"
  PopupMenuItem<String> _construireElementMenuSauvegarder() {
    return PopupMenuItem<String>(
      value: 'sauvegarder',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Row(
          children: [
            Icon(Icons.save, size: 20, color: Colors.blue),
            SizedBox(width: 12),
            Text('Sauvegarder', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Construit l'élément de menu "Exporter en PDF"
  PopupMenuItem<String> _construireElementMenuExporterPdf() {
    return PopupMenuItem<String>(
      value: 'exporter_pdf',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text('Exporter en PDF', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Construit l'élément de menu "Exporter en TXT"
  PopupMenuItem<String> _construireElementMenuExporterTxt() {
    return PopupMenuItem<String>(
      value: 'exporter_txt',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Row(
          children: [
            Icon(Icons.text_snippet, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Text('Exporter en TXT', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Construit l'élément de menu "Supprimer"
  PopupMenuItem<String> _construireElementMenuSupprimer() {
    return PopupMenuItem<String>(
      value: 'supprimer',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text('Supprimer', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Gère la sélection d'un élément du menu
  Future<void> _gererSelectionMenu(String valeur) async {
    switch (valeur) {
      case 'exporter_pdf':
        await onExporterPdf();
        break;
      case 'exporter_txt':
        await onExporterTxt();
        break;
      case 'sauvegarder':
        onSauvegarder();
        break;
      case 'supprimer':
        onSupprimer();
        break;
    }
  }

  /// Construit le champ de texte pour la transcription
  Widget _construireChampTranscription() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controleurTranscription,
        maxLines: null,
        minLines: 8,
        style: StylesTexte.corps.copyWith(
          fontSize: 16,
          height: 1.6,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: 'La transcription apparaîtra ici...',
          hintStyle: StylesTexte.corps.copyWith(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(DimensionsApplication.paddingL),
          filled: false,
        ),
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
} 