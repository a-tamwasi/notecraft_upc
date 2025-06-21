import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_profile_service.dart';

/// État de l'image de profil
class EtatImageProfil {
  final String? cheminImage;
  final bool estEnCoursDeChargement;
  final String? messageErreur;

  const EtatImageProfil({
    this.cheminImage,
    this.estEnCoursDeChargement = false,
    this.messageErreur,
  });

  EtatImageProfil copyWith({
    String? cheminImage,
    bool? estEnCoursDeChargement,
    String? messageErreur,
  }) {
    return EtatImageProfil(
      cheminImage: cheminImage ?? this.cheminImage,
      estEnCoursDeChargement: estEnCoursDeChargement ?? this.estEnCoursDeChargement,
      messageErreur: messageErreur ?? this.messageErreur,
    );
  }
}

/// Notifier pour gérer l'image de profil
class ImageProfilNotifier extends StateNotifier<EtatImageProfil> {
  final ImageProfilService _imageService;

  ImageProfilNotifier(this._imageService) : super(const EtatImageProfil());

  /// Charge l'image de profil existante
  Future<void> chargerImageProfil(String? cheminImage) async {
    if (cheminImage != null && await _imageService.imageExiste(cheminImage)) {
      state = state.copyWith(cheminImage: cheminImage);
    }
  }

  /// Sélectionne et sauvegarde une nouvelle image de profil
  Future<String?> changerImageProfil({bool depuisCamera = false}) async {
    state = state.copyWith(estEnCoursDeChargement: true, messageErreur: null);

    try {
      // Sélectionner l'image
      final imageSelectionnee = await _imageService.selectionnerImage(depuisCamera: depuisCamera);
      if (imageSelectionnee == null) {
        state = state.copyWith(estEnCoursDeChargement: false);
        return null;
      }

      // Supprimer l'ancienne image si elle existe
      if (state.cheminImage != null) {
        await _imageService.supprimerImage(state.cheminImage!);
      }

      // Sauvegarder la nouvelle image
      final nouveauChemin = await _imageService.sauvegarderImage(imageSelectionnee);
      
      state = state.copyWith(
        cheminImage: nouveauChemin,
        estEnCoursDeChargement: false,
      );

      return nouveauChemin;
    } catch (e) {
      state = state.copyWith(
        estEnCoursDeChargement: false,
        messageErreur: e.toString(),
      );
      return null;
    }
  }

  /// Supprime l'image de profil actuelle
  Future<void> supprimerImageProfil() async {
    if (state.cheminImage != null) {
      await _imageService.supprimerImage(state.cheminImage!);
      state = state.copyWith(cheminImage: null);
    }
  }
}

/// Provider pour le service d'image de profil
final imageProfilServiceProvider = Provider<ImageProfilService>((ref) {
  return ImageProfilService();
});

/// Provider pour le notifier de l'image de profil
final imageProfilProvider = StateNotifierProvider<ImageProfilNotifier, EtatImageProfil>((ref) {
  final service = ref.watch(imageProfilServiceProvider);
  return ImageProfilNotifier(service);
}); 