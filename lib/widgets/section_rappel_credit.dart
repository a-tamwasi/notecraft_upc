import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Widget pour afficher la section de rappel des crédits de transcription
/// 
/// Affiche de manière discrète les crédits restants sous forme de barre
/// de progression avec un bouton pour recharger les crédits.
class SectionRappelCredit extends StatelessWidget {
  /// Nombre de secondes de crédit restantes
  final int creditSecondesRestantes;
  
  /// Nombre total de secondes de crédit
  final int creditSecondesTotal;
  
  /// Callback appelé quand l'utilisateur souhaite acheter plus de crédits
  final VoidCallback onAcheterCredits;

  const SectionRappelCredit({
    super.key,
    required this.creditSecondesRestantes,
    required this.creditSecondesTotal,
    required this.onAcheterCredits,
  });

  @override
  Widget build(BuildContext context) {
    // Calculs pour l'affichage
    final minutesRestantes = (creditSecondesRestantes / 60).floor();
    final minutesTotales = (creditSecondesTotal / 60).floor();
    final progression = (creditSecondesTotal > 0) ? creditSecondesRestantes / creditSecondesTotal : 0.0;

    return Card(
      elevation: 2.0, // Ombre plus subtile
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        // Padding réduit pour un design plus compact
        padding: const EdgeInsets.symmetric(
            vertical: DimensionsApplication.paddingM,
            horizontal: DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construireEnTete(minutesRestantes),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            _construireBarreProgression(progression),
            const SizedBox(height: DimensionsApplication.paddingS),
            _construireTexteProgression(minutesRestantes, minutesTotales),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête avec l'icône, le texte et le bouton recharger
  Widget _construireEnTete(int minutesRestantes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _construireInfosCredit(minutesRestantes),
        const SizedBox(width: 8), // Espacement de sécurité
        _construireBoutonRecharger(),
      ],
    );
  }

  /// Construit la partie gauche avec l'icône et les minutes restantes
  Widget _construireInfosCredit(int minutesRestantes) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.grey[600], // Icône plus claire
            size: 20, // Icône plus petite
          ),
          const SizedBox(width: DimensionsApplication.paddingS),
          Flexible(
            child: Text(
              '$minutesRestantes min',
              style: StylesTexte.corps.copyWith(
                fontSize: 14, 
                color: Colors.grey[800]
              ),
              overflow: TextOverflow.ellipsis, // Empêche le texte de déborder
              softWrap: false, // Empêche le retour à la ligne
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton de rechargement des crédits
  Widget _construireBoutonRecharger() {
    return FilledButton.tonalIcon(
      onPressed: onAcheterCredits,
      icon: const Icon(Iconsax.add_square, size: 18),
      label: const Text('Recharger'),
      style: FilledButton.styleFrom(
        // Utilise les couleurs du thème pour une intégration parfaite
        foregroundColor: CouleursApplication.primaire,
        backgroundColor: CouleursApplication.primaire.withOpacity(0.1),
        // Un padding équilibré pour une apparence soignée
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // Un style de texte cohérent avec le reste de l'application
        textStyle: StylesTexte.corpsPetit.copyWith(fontWeight: FontWeight.bold),
        // Assure que le bouton ne prend pas plus de place que nécessaire
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // Une bordure subtile pour délimiter le bouton
        side: BorderSide(
          color: CouleursApplication.primaire.withOpacity(0.2)
        ),
      ),
    );
  }

  /// Construit la barre de progression des crédits
  Widget _construireBarreProgression(double progression) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
      child: LinearProgressIndicator(
        value: progression,
        minHeight: 6, // Hauteur réduite
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(
          CouleursApplication.primaire
        ),
      ),
    );
  }

  /// Construit le texte informatif sur la progression
  Widget _construireTexteProgression(int minutesRestantes, int minutesTotales) {
    return Text(
      '$minutesRestantes min restantes sur $minutesTotales min',
      // Texte plus petit et discret
      style: StylesTexte.corpsPetit.copyWith(
        color: Colors.grey[600], 
        fontSize: 11
      ),
    );
  }
} 