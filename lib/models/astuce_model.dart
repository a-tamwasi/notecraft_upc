/// Modèle représentant une astuce pour l'utilisateur.
class AstuceModel {
  /// Le titre de l'astuce (ex: "Astuce de la semaine").
  final String titre;

  /// Le contenu textuel de l'astuce.
  final String contenu;

  /// Le chemin vers l'image de fond de la carte.
  final String cheminImage;

  AstuceModel({
    required this.titre,
    required this.contenu,
    required this.cheminImage,
  });
} 