import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service pour gérer les images de profil utilisateur
class ImageProfilService {
  static const String _dossierImagesProfil = 'images_profil';
  final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis la galerie ou prend une photo avec la caméra
  Future<File?> selectionnerImage({bool depuisCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: depuisCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Sauvegarde l'image dans le dossier de l'application
  Future<String> sauvegarderImage(File imageFile) async {
    try {
      // Obtenir le répertoire de documents de l'application
      final repertoireApp = await getApplicationDocumentsDirectory();
      final dossierImages = Directory(path.join(repertoireApp.path, _dossierImagesProfil));
      
      // Créer le dossier s'il n'existe pas
      if (!await dossierImages.exists()) {
        await dossierImages.create(recursive: true);
      }

      // Générer un nom unique pour l'image
      final extension = path.extension(imageFile.path);
      final nomFichier = 'profil_${DateTime.now().millisecondsSinceEpoch}$extension';
      final cheminDestination = path.join(dossierImages.path, nomFichier);

      // Copier l'image
      final nouvellImage = await imageFile.copy(cheminDestination);
      return nouvellImage.path;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'image: $e');
    }
  }

  /// Supprime une image de profil existante
  Future<void> supprimerImage(String cheminImage) async {
    try {
      final fichier = File(cheminImage);
      if (await fichier.exists()) {
        await fichier.delete();
      }
    } catch (e) {
      // Log l'erreur mais ne pas la propager car ce n'est pas critique
      print('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Vérifie si un fichier image existe
  Future<bool> imageExiste(String? cheminImage) async {
    if (cheminImage == null) return false;
    return await File(cheminImage).exists();
  }
} 