/// Classe contenant toutes les dimensions utilisées dans l'application
/// Centralise les valeurs de padding, margin, tailles, etc.
class DimensionsApplication {
  // Empêche l'instanciation de la classe
  DimensionsApplication._();

  // === PADDING ===
  /// Padding très petit (4.0)
  static const double paddingXS = 4.0;

  /// Padding petit (8.0)
  static const double paddingS = 8.0;

  /// Padding moyen (16.0)
  static const double paddingM = 16.0;

  /// Padding large (24.0)
  static const double paddingL = 24.0;

  /// Padding très large (32.0)
  static const double paddingXL = 32.0;

  // === MARGIN ===
  /// Marge standard entre les éléments (16.0)
  static const double margeStandard = 16.0;

  /// Marge entre les sections (32.0)
  static const double margeSection = 32.0;

  // === RADIUS ===
  /// Radius petit pour les bordures (4.0)
  static const double radiusS = 4.0;

  /// Radius moyen pour les bordures (8.0)
  static const double radiusM = 8.0;

  /// Radius large pour les bordures (16.0)
  static const double radiusL = 16.0;

  /// Radius circulaire (999.0)
  static const double radiusCirculaire = 999.0;

  // === TAILLES D'ICÔNES ===
  /// Taille d'icône petite (16.0)
  static const double iconeS = 16.0;

  /// Taille d'icône moyenne (24.0)
  static const double iconeM = 24.0;

  /// Taille d'icône large (32.0)
  static const double iconeL = 32.0;

  /// Taille d'icône très large (48.0)
  static const double iconeXL = 48.0;

  // === HAUTEURS ===
  /// Hauteur standard d'un bouton (48.0)
  static const double hauteurBouton = 48.0;

  /// Hauteur de l'app bar (56.0)
  static const double hauteurAppBar = 56.0;

  /// Hauteur d'un champ de texte (56.0)
  static const double hauteurChampTexte = 56.0;

  // === LARGEURS ===
  /// Largeur maximale du contenu sur grand écran (600.0)
  static const double largeurMaxContenu = 600.0;

  /// Largeur minimale d'un bouton (120.0)
  static const double largeurMinBouton = 120.0;

  // === ÉPAISSEURS ===
  /// Épaisseur de bordure fine (1.0)
  static const double epaisseurBordureFine = 1.0;

  /// Épaisseur de bordure normale (2.0)
  static const double epaisseurBordureNormale = 2.0;

  /// Épaisseur de bordure épaisse (3.0)
  static const double epaisseurBordureEpaisse = 3.0;
} 