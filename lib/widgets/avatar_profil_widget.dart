import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_profil_provider.dart';
import '../src/constants/couleurs_application.dart';

/// Widget pour afficher et modifier l'avatar de profil utilisateur
class AvatarProfilWidget extends ConsumerWidget {
  final double rayon;
  final bool peutModifier;
  final VoidCallback? surChangement;

  const AvatarProfilWidget({
    super.key,
    this.rayon = 65.0,
    this.peutModifier = false,
    this.surChangement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etatImageProfil = ref.watch(imageProfilProvider);

    return Stack(
      children: [
        // Avatar principal
        CircleAvatar(
          radius: rayon,
          backgroundColor: CouleursApplication.primaire.shade100,
          backgroundImage: _obtenirImageProvider(etatImageProfil.cheminImage),
          child: etatImageProfil.cheminImage == null
              ? Icon(
                  Icons.person,
                  size: rayon,
                  color: const Color(0xFF666666),
                )
              : null,
        ),
        
        // Indicateur de chargement
        if (etatImageProfil.estEnCoursDeChargement)
          Positioned.fill(
            child: CircleAvatar(
              radius: rayon,
              backgroundColor: Colors.black54,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        
        // Bouton pour modifier l'image
        if (peutModifier)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _changerImage(context, ref),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CouleursApplication.primaire,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Obtient le provider d'image approprié
  ImageProvider? _obtenirImageProvider(String? cheminImage) {
    if (cheminImage != null && File(cheminImage).existsSync()) {
      return FileImage(File(cheminImage));
    }
    return null;
  }

  /// Gère le changement d'image
  Future<void> _changerImage(BuildContext context, WidgetRef ref) async {
    // Afficher le menu de choix
    final choix = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MenuChoixImage(),
    );

    if (choix == null) return;

    final notifier = ref.read(imageProfilProvider.notifier);

    switch (choix) {
      case 'galerie':
        final nouveauChemin = await notifier.changerImageProfil(depuisCamera: false);
        if (nouveauChemin != null && surChangement != null) {
          surChangement!();
        }
        break;
      case 'camera':
        final nouveauChemin = await notifier.changerImageProfil(depuisCamera: true);
        if (nouveauChemin != null && surChangement != null) {
          surChangement!();
        }
        break;
      case 'supprimer':
        await notifier.supprimerImageProfil();
        if (surChangement != null) {
          surChangement!();
        }
        break;
    }

    // Afficher un message d'erreur si nécessaire
    if (context.mounted) {
      final etat = ref.read(imageProfilProvider);
      if (etat.messageErreur != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${etat.messageErreur}'),
            backgroundColor: CouleursApplication.erreur,
          ),
        );
      }
    }
  }
}

/// Menu de choix pour les actions sur l'image de profil
class _MenuChoixImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur visuel du bottom sheet
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 20),
          
          // Titre
          const Text(
            'Photo de profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Options
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir depuis la galerie'),
            onTap: () => Navigator.pop(context, 'galerie'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(context, 'supprimer'),
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Annuler'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
} 