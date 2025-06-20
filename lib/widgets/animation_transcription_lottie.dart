import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Widget d'animation Lottie pour l'indicateur de transcription en cours
/// 
/// Affiche une animation de plume/parchemin avec le texte de transcription en cours
class AnimationTranscriptionLottie extends StatelessWidget {
  /// Texte à afficher sous l'animation
  final String texte;
  
  /// Taille de l'animation (par défaut: 120)
  final double taille;

  const AnimationTranscriptionLottie({
    super.key,
    this.texte = 'Transcription en cours...',
    this.taille = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animation Lottie
        SizedBox(
          width: taille,
          height: taille,
          child: Lottie.asset(
            'assets/images/Animation - 1750430619033.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),
        ),
        const SizedBox(height: DimensionsApplication.paddingM),
        // Texte de chargement
        Text(
          texte,
          style: StylesTexte.corps.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 