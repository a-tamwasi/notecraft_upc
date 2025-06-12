import 'package:flutter/material.dart';

/// Classe contenant toutes les couleurs de l'application NoteCraft
/// À personnaliser selon la palette de couleurs choisie
class CouleursApplication {
  // Empêche l'instanciation de la classe
  CouleursApplication._();

  /// Couleur primaire de l'application
  /// TODO: Remplacer par la couleur primaire choisie
  static const MaterialColor primaire = Colors.blue;

  /// Couleur secondaire de l'application
  /// TODO: Remplacer par la couleur secondaire choisie
  static const Color secondaire = Color(0xFF03DAC6);

  /// Couleur d'accent pour les actions importantes
  /// TODO: Remplacer par la couleur d'accent choisie
  static const Color accent = Color(0xFFFF6B6B);

  /// Couleur de fond principale
  static const Color fondPrincipal = Color(0xFFF5F5F5);

  /// Couleur de fond secondaire (cartes, conteneurs)
  static const Color fondSecondaire = Colors.white;

  /// Couleur du texte principal
  static const Color textePrincipal = Color(0xFF212121);

  /// Couleur du texte secondaire
  static const Color texteSecondaire = Color(0xFF757575);

  /// Couleur pour les erreurs
  static const Color erreur = Color(0xFFB00020);

  /// Couleur pour les succès
  static const Color succes = Color(0xFF4CAF50);

  /// Couleur pour les avertissements
  static const Color avertissement = Color(0xFFFFC107);

  /// Couleur pour les informations
  static const Color info = Color(0xFF2196F3);

  /// Couleur de l'ombre
  static const Color ombre = Color(0x1F000000);

  /// Couleur de la bordure
  static const Color bordure = Color(0xFFE0E0E0);
} 