import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Vue principale pour la transcription audio
/// Affiche l'interface utilisateur pour enregistrer ou importer des audios
class TranscriptionView extends StatelessWidget {
  const TranscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApplication.fondPrincipal,
      appBar: AppBar(
        title: const Text('Transcription Audio'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: CouleursApplication.primaire,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DimensionsApplication.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section d'enregistrement
              _construireSectionEnregistrement(),
              const SizedBox(height: DimensionsApplication.margeSection),
              
              // Divider avec texte
              _construireDividerOu(),
              const SizedBox(height: DimensionsApplication.margeSection),
              
              // Section d'import
              _construireSectionImport(),
              const SizedBox(height: DimensionsApplication.margeSection),
              
              // Liste des transcriptions récentes
              Expanded(
                child: _construireListeTranscriptions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la section d'enregistrement audio
  Widget _construireSectionEnregistrement() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.paddingL),
        child: Column(
          children: [
            Icon(
              Icons.mic,
              size: DimensionsApplication.iconeXL,
              color: CouleursApplication.primaire,
            ),
            const SizedBox(height: DimensionsApplication.paddingM),
            Text(
              'Enregistrer un audio',
              style: StylesTexte.sousTitre,
            ),
            const SizedBox(height: DimensionsApplication.paddingS),
            Text(
              'Appuyez pour commencer l\'enregistrement',
              style: StylesTexte.corpsSecondaire,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DimensionsApplication.paddingL),
            // TODO: Remplacer par un bouton d'enregistrement fonctionnel
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implémenter la logique d'enregistrement
              },
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Commencer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  DimensionsApplication.largeurMinBouton,
                  DimensionsApplication.hauteurBouton,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le divider "OU"
  Widget _construireDividerOu() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: CouleursApplication.bordure,
            thickness: DimensionsApplication.epaisseurBordureFine,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionsApplication.paddingM,
          ),
          child: Text(
            'OU',
            style: StylesTexte.corpsSecondaire,
          ),
        ),
        const Expanded(
          child: Divider(
            color: CouleursApplication.bordure,
            thickness: DimensionsApplication.epaisseurBordureFine,
          ),
        ),
      ],
    );
  }

  /// Construit la section d'import de fichier
  Widget _construireSectionImport() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implémenter l'import de fichier
        },
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(DimensionsApplication.paddingL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: DimensionsApplication.iconeL,
                color: CouleursApplication.primaire,
              ),
              const SizedBox(width: DimensionsApplication.paddingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Importer un fichier audio',
                    style: StylesTexte.sousTitre,
                  ),
                  const SizedBox(height: DimensionsApplication.paddingXS),
                  Text(
                    'MP3, WAV, M4A, etc.',
                    style: StylesTexte.corpsPetit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la liste des transcriptions récentes
  Widget _construireListeTranscriptions() {
    // TODO: Connecter avec le contrôleur pour afficher les vraies transcriptions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transcriptions récentes',
          style: StylesTexte.titreSection,
        ),
        const SizedBox(height: DimensionsApplication.paddingM),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: DimensionsApplication.iconeXL,
                  color: CouleursApplication.texteSecondaire.withOpacity(0.5),
                ),
                const SizedBox(height: DimensionsApplication.paddingM),
                Text(
                  'Aucune transcription pour le moment',
                  style: StylesTexte.corpsSecondaire,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 