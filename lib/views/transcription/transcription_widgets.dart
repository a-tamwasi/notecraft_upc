import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/styles_texte.dart';

/// Widget pour afficher le chronomètre d'enregistrement
class ChronometreEnregistrement extends StatelessWidget {
  final int secondsElapsed;
  final bool isRecording;
  final bool isPaused;

  const ChronometreEnregistrement({
    Key? key,
    required this.secondsElapsed,
    required this.isRecording,
    required this.isPaused,
  }) : super(key: key);

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isRecording 
          ? (isPaused ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1))
          : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecording 
            ? (isPaused ? Colors.orange : Colors.red)
            : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaused ? Iconsax.pause : (isRecording ? Iconsax.record : Iconsax.stop),
            color: isRecording 
              ? (isPaused ? Colors.orange : Colors.red)
              : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(secondsElapsed),
            style: StylesTexte.bouton.copyWith(
              color: isRecording 
                ? (isPaused ? Colors.orange : Colors.red)
                : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour le bouton d'enregistrement principal
class BoutonEnregistrementPrincipal extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onToggleRecording;
  final VoidCallback onStopRecording;

  const BoutonEnregistrementPrincipal({
    Key? key,
    required this.isRecording,
    required this.isPaused,
    required this.onToggleRecording,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton principal d'enregistrement
        GestureDetector(
          onTap: onToggleRecording,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRecording
                  ? (isPaused 
                      ? [Colors.orange.shade400, Colors.orange.shade600]
                      : [Colors.red.shade400, Colors.red.shade600])
                  : [CouleursApplication.primaire.shade400, CouleursApplication.primaire.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isRecording 
                    ? (isPaused ? Colors.orange : Colors.red)
                    : CouleursApplication.primaire).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isPaused 
                ? Iconsax.play 
                : (isRecording ? Iconsax.pause : Iconsax.microphone_2),
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isPaused 
            ? 'Reprendre' 
            : (isRecording ? 'Pause' : 'Appuyez pour enregistrer'),
          style: StylesTexte.bouton.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        
        // Bouton d'arrêt (visible seulement pendant l'enregistrement)
        if (isRecording) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onStopRecording,
            icon: const Icon(Iconsax.stop, color: Colors.white),
            label: const Text('Arrêter et transcrire', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
