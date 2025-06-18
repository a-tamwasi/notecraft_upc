import 'package:flutter/material.dart';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA VUE DES PARAMÈTRES
// --- //

/// La vue `VueParametres` affiche les options de configuration de l'application.
///
/// Elle utilise un `Scaffold` pour obtenir une structure de page standard
/// avec une `AppBar` (barre de titre) et un `body` (corps).
class VueParametres extends StatelessWidget {
  const VueParametres({super.key});

  @override
  Widget build(BuildContext context) {
    // Le `Scaffold` fournit la structure visuelle de base de la page.
    return Scaffold(
      // L'`AppBar` est la barre située en haut de l'écran.
      appBar: AppBar(
        // Le `title` est le texte principal affiché dans l'AppBar.
        title: const Text('Paramètres'),
        // `centerTitle: true` centre le titre, ce qui est commun sur iOS.
        centerTitle: true,
      ),
      // Le `body` est le contenu principal de la page.
      body: const Center(
        child: Text(
          'Page des paramètres (en construction)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 