import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';
import '../controllers/audio_recorder_controller.dart';
import 'animation_transcription_lottie.dart';

/// Widget pour afficher la section d'enregistrement audio
/// 
/// Contient le bouton principal d'enregistrement/pause/reprise,
/// le bouton d'arrêt, le chronomètre et le bouton d'import.
class SectionEnregistrement extends StatelessWidget {
  /// Indique si un enregistrement est en cours
  final bool estEnregistrement;
  
  /// Indique si l'enregistrement est en pause
  final bool estEnPause;
  
  /// Indique si une importation est en cours
  final bool estImportation;
  
  /// Indique si une transcription est en cours
  final bool estTranscription;
  
  /// Contrôleur audio pour accéder au chronomètre en temps réel
  final AudioRecorderController audioRecorderController;
  
  /// Callback appelé pour basculer l'enregistrement (start/pause/resume)
  final VoidCallback onToggleEnregistrement;
  
  /// Callback appelé pour arrêter l'enregistrement
  final VoidCallback onArreterEnregistrement;
  
  /// Callback appelé pour importer un fichier audio
  final VoidCallback onImporterAudio;

  const SectionEnregistrement({
    super.key,
    required this.estEnregistrement,
    required this.estEnPause,
    required this.estImportation,
    required this.estTranscription,
    required this.audioRecorderController,
    required this.onToggleEnregistrement,
    required this.onArreterEnregistrement,
    required this.onImporterAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: DimensionsApplication.paddingXL,
            horizontal: DimensionsApplication.paddingL),
        child: Column(
          children: [
            _construireBoutonPrincipal(),
            _construireBoutonArret(),
            const SizedBox(height: DimensionsApplication.margeGrande),
            _construireChronometre(),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            _construireIndicateursEtat(),
          ],
        ),
      ),
    );
  }

  /// Construit le bouton principal (Enregistrer/Pause/Reprendre)
  Widget _construireBoutonPrincipal() {
    return ElevatedButton.icon(
      onPressed: (estImportation || estTranscription) ? null : onToggleEnregistrement,
      icon: Icon(
        _obtenirIconeBoutonPrincipal(),
        color: Colors.white
      ),
      label: Text(
        _obtenirTexteBoutonPrincipal(),
        style: StylesTexte.corps.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _obtenirCouleurBoutonPrincipal(),
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: DimensionsApplication.paddingM,
          horizontal: DimensionsApplication.paddingL,
        ),
      ),
    );
  }

  /// Construit le bouton d'arrêt (visible seulement pendant l'enregistrement)
  Widget _construireBoutonArret() {
    if (!estEnregistrement) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: DimensionsApplication.paddingM),
        ElevatedButton.icon(
          onPressed: onArreterEnregistrement,
          icon: const Icon(Icons.stop, color: Colors.white),
          label: Text(
            'Arrêter l\'enregistrement',
            style: StylesTexte.corps.copyWith(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: DimensionsApplication.paddingM,
              horizontal: DimensionsApplication.paddingL,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit le chronomètre ou l'animation selon l'état
  /// Affiche l'animation pendant la transcription/importation, le chronomètre pendant l'enregistrement
  Widget _construireChronometre() {
    // Si transcription en cours, afficher l'animation
    if (estTranscription) {
      return const AnimationTranscriptionLottie(
        texte: 'Transcription en cours...',
        taille: 200,
      );
    }
    
    // Si importation en cours, afficher l'animation
    if (estImportation) {
      return const AnimationTranscriptionLottie(
        texte: 'Importation en cours...',
        taille: 120,
      );
    }
    
    // Si enregistrement actif, afficher le chronomètre
    if (estEnregistrement) {
      return ValueListenableBuilder<int>(
        valueListenable: audioRecorderController.secondesEcoulees,
        builder: (context, secondes, child) {
          return Text(
            audioRecorderController.formatDuration(secondes),
            style: StylesTexte.titrePrincipal.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          );
        },
      );
    }
    
    // État par défaut : chronomètre à 00:00
    return Text(
      '00:00',
      style: StylesTexte.titrePrincipal.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.grey[400],
      ),
    );
  }

  /// Construit les éléments d'interaction en bas (bouton import)
  Widget _construireIndicateursEtat() {
    // Si transcription ou importation en cours, ne pas afficher le bouton
    if (estTranscription || estImportation) {
      return const SizedBox.shrink();
    }
    
    return _construireBoutonImport();
  }

  /// Construit le bouton d'importation de fichier audio
  Widget _construireBoutonImport() {
    return ElevatedButton.icon(
      onPressed: (estEnregistrement || estTranscription) ? null : onImporterAudio,
      icon: const Icon(Icons.upload_file, color: Colors.white),
      label: Text(
        'Importer un fichier audio',
        style: StylesTexte.corps.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApplication.secondaire,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: DimensionsApplication.paddingM,
          horizontal: DimensionsApplication.paddingL,
        ),
      ),
    );
  }

  /// Détermine l'icône du bouton principal selon l'état
  IconData _obtenirIconeBoutonPrincipal() {
    if (estEnregistrement) {
      return estEnPause ? Icons.play_arrow : Icons.pause;
    } else {
      return Icons.mic;
    }
  }

  /// Détermine le texte du bouton principal selon l'état
  String _obtenirTexteBoutonPrincipal() {
    if (estEnregistrement) {
      return estEnPause ? 'Reprendre l\'enregistrement' : 'Mettre en pause';
    } else {
      return 'Enregistrer Audio';
    }
  }

  /// Détermine la couleur du bouton principal selon l'état
  Color _obtenirCouleurBoutonPrincipal() {
    if (estEnregistrement) {
      return estEnPause ? Colors.green : Colors.orange;
    } else {
      return CouleursApplication.primaire;
    }
  }
} 