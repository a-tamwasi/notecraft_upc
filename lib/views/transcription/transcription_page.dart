import 'package:flutter/material.dart';
import 'transcription_view.dart';

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
    return const TranscriptionView();
  }
} 