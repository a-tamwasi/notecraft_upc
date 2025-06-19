import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

// --- //
// 1. WIDGET RÉUTILISABLE POUR LES OPTIONS DE PARAMÈTRES
// --- //

/// Widget personnalisé pour afficher une option de paramètre.
///
/// Ce widget présente une interface cohérente pour toutes les options
/// de paramètres avec :
/// - Une icône à gauche
/// - Un texte descriptif au centre
/// - Une flèche de navigation à droite
/// - Support pour l'interaction tactile
class ParametreOptionWidget extends StatelessWidget {
  /// L'icône à afficher à gauche de l'option
  final IconData icone;
  
  /// Le texte descriptif de l'option
  final String titre;
  
  /// Fonction callback exécutée lors du tap (optionnelle)
  final VoidCallback? onTap;
  
  /// Couleur personnalisée pour l'icône (optionnelle)
  final Color? couleurIcone;

  const ParametreOptionWidget({
    super.key,
    required this.icone,
    required this.titre,
    this.onTap,
    this.couleurIcone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // --- ICÔNE À GAUCHE ---
      leading: Icon(
        icone,
        color: couleurIcone ?? CouleursApplication.texteSecondaire,
        size: DimensionsApplication.iconeM,
      ),
      
      // --- TITRE DE L'OPTION ---
      title: Text(
        titre,
        style: StylesTexte.corps.copyWith(
          fontWeight: FontWeight.w400,
          color: CouleursApplication.textePrincipal,
        ),
      ),
      
      // --- FLÈCHE DE NAVIGATION À DROITE ---
      trailing: Icon(
        Icons.chevron_right,
        color: CouleursApplication.texteSecondaire,
        size: DimensionsApplication.iconeM,
      ),
      
      // --- GESTION DU TAP ---
      onTap: onTap,
      
      // Configuration visuelle du ListTile
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.paddingL,
        vertical: DimensionsApplication.paddingS,
      ),
    );
  }
} 