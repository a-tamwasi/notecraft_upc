import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Widget pour afficher la section de transcription avec amélioration IA
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
  
  /// Callback appelé lors de l'amélioration de la transcription
  final VoidCallback? onEnhanceTranscription;
  
  /// Callback appelé lors de la bascule entre les versions brute et améliorée
  final VoidCallback? onToggleDisplayMode;
  
  /// État indiquant si la transcription est en cours d'amélioration
  final bool isEnhancing;
  
  /// Indicateur indiquant si une version améliorée existe
  final bool hasEnhancedVersion;
  
  /// Indicateur indiquant quelle version est affichée
  final bool showEnhanced;

  const SectionTranscription({
    super.key,
    required this.controleurTranscription,
    required this.cle,
    required this.onExporterPdf,
    required this.onExporterTxt,
    required this.onSauvegarder,
    required this.onSupprimer,
    this.onEnhanceTranscription,
    this.onToggleDisplayMode,
    this.isEnhancing = false,
    this.hasEnhancedVersion = false,
    this.showEnhanced = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: cle,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construireEnTete(context),
        const SizedBox(height: DimensionsApplication.paddingM),
        if (hasEnhancedVersion) _construireToggleButtons(context),
        if (hasEnhancedVersion) const SizedBox(height: DimensionsApplication.paddingS),
        _construireChampTranscription(context),
      ],
    );
  }

  /// Construit l'en-tête avec titre et menu d'actions
  Widget _construireEnTete(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: DimensionsApplication.paddingS),
          child: Text(
            'Transcription',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
        ),
        Row(
          children: [
            // Bouton "baguette magique" pour améliorer
            if (onEnhanceTranscription != null)
              Tooltip(
                message: 'Améliorer la transcription avec l\'IA',
                child: IconButton(
                  onPressed: isEnhancing ? null : onEnhanceTranscription,
                  icon: isEnhancing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high, color: Colors.purple),
                  tooltip: 'Améliorer avec GPT-4o',
                ),
              ),
            _construireMenuActions(),
          ],
        ),
      ],
    );
  }

  /// Construit le menu d'actions avec PopupMenuButton
  Widget _construireMenuActions() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: _gererSelectionMenu,
      itemBuilder: (BuildContext context) => [
        _construireElementMenu('sauvegarder', 'Sauvegarder', Icons.save_alt, Colors.blue),
        _construireElementMenu('exporter_pdf', 'Exporter en PDF', Icons.picture_as_pdf, Colors.red),
        _construireElementMenu('exporter_txt', 'Exporter en TXT', Icons.description, Colors.green),
        const PopupMenuDivider(),
        _construireElementMenu('supprimer', 'Effacer le texte', Icons.delete_sweep_outlined, Colors.orange),
      ],
    );
  }

  /// Factorisation de la construction des éléments de menu
  PopupMenuItem<String> _construireElementMenu(String valeur, String texte, IconData icone, Color couleurIcone) {
    return PopupMenuItem<String>(
      value: valeur,
      child: Row(
        children: [
          Icon(icone, color: couleurIcone, size: 22),
          const SizedBox(width: DimensionsApplication.paddingM),
          Text(texte),
        ],
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

  /// Construit le champ de texte pour la transcription, adaptatif selon le clavier
  Widget _construireChampTranscription(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double screenHeight = mediaQuery.size.height;
    final double availableHeight = screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;
    
    // Calculer la hauteur optimale selon l'état du clavier
    late final double fieldHeight;
    
    if (keyboardHeight > 0) {
      // Clavier ouvert : utiliser l'espace disponible au-dessus du clavier
      // en laissant de la place pour les autres éléments de l'interface
      fieldHeight = (availableHeight - keyboardHeight - 200).clamp(200.0, 400.0);
    } else {
      // Clavier fermé : utiliser une hauteur standard adaptée à l'écran
      fieldHeight = (availableHeight * 0.45).clamp(300.0, 500.0);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 200,
            maxHeight: fieldHeight,
          ),
          child: Material(
            color: Colors.white,
            elevation: 1.0,
            borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
            shadowColor: Colors.grey.shade100,
            child: Scrollbar(
              child: TextField(
                controller: controleurTranscription,
                maxLines: null,
                expands: false,
                minLines: 8,
                textAlignVertical: TextAlignVertical.top,
                style: StylesTexte.corps.copyWith(fontSize: 15, height: 1.5),
                scrollPadding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? keyboardHeight + 100 : 100,
                ),
                decoration: InputDecoration(
                  hintText: 'La transcription apparaîtra ici...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(DimensionsApplication.paddingL),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
                    borderSide: BorderSide(color: CouleursApplication.primaire, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                // Améliorer le comportement du scroll avec le clavier
                onTap: () {
                  // Scroll automatique vers le curseur quand on clique dans le champ
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (keyboardHeight > 0) {
                      Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                      );
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construireToggleButtons(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: [!showEnhanced, showEnhanced],
        onPressed: (index) => onToggleDisplayMode?.call(),
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
    );
  }
} 