import 'package:flutter/material.dart';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA PAGE DE TRANSCRIPTION
// --- //

/// Un `StatelessWidget` est un widget qui ne change pas d'état une fois construit.
/// Il est défini par ses propriétés initiales et ne sera redessiné que si ces propriétés changent
/// depuis son widget parent. C'est idéal pour des pages ou des composants d'interface statiques.
class PageTranscription extends StatelessWidget {
  /// Le constructeur. `const` signifie que le widget peut être optimisé par le compilateur
  /// s'il est créé avec des valeurs connues à la compilation.
  const PageTranscription({super.key});

  /// La méthode `build` décrit l'interface du widget.
  @override
  Widget build(BuildContext context) {
    // Le `Container` sert de fond de page, ici de couleur blanche.
    return Container(
      color: Colors.white,
      // `Center` est un widget qui centre son enfant à la fois horizontalement et verticalement.
      child: const Center(
        // Le `Text` est le widget qui affiche une chaîne de caractères.
        child: Text(
          'Transcription',
          style: TextStyle(fontSize: 24), // Style pour la taille de la police.
        ),
      ),
    );
  }
} 