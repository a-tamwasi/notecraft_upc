import 'package:flutter/material.dart';
import 'couleurs_application.dart';

/// Classe contenant tous les styles de texte de l'application
/// Centralise la typographie pour une cohérence visuelle
class StylesTexte {
  // Empêche l'instanciation de la classe
  StylesTexte._();

  // === TITRES ===
  /// Style pour les très grands titres
  static const TextStyle titrePrincipal = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: CouleursApplication.textePrincipal,
    height: 1.2,
  );

  /// Style pour les titres de sections
  static const TextStyle titreSection = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: CouleursApplication.textePrincipal,
    height: 1.3,
  );

  /// Style pour les sous-titres
  static const TextStyle sousTitre = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: CouleursApplication.textePrincipal,
    height: 1.4,
  );

  // === CORPS DE TEXTE ===
  /// Style pour le texte normal
  static const TextStyle corps = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.textePrincipal,
    height: 1.5,
  );

  /// Style pour le texte secondaire
  static const TextStyle corpsSecondaire = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.texteSecondaire,
    height: 1.5,
  );

  /// Style pour le texte petit
  static const TextStyle corpsPetit = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.texteSecondaire,
    height: 1.4,
  );

  // === BOUTONS ===
  /// Style pour le texte des boutons
  static const TextStyle bouton = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Style pour le texte des boutons secondaires
  static const TextStyle boutonSecondaire = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.2,
  );

  // === CHAMPS DE FORMULAIRE ===
  /// Style pour les labels de formulaire
  static const TextStyle labelFormulaire = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: CouleursApplication.texteSecondaire,
    height: 1.2,
  );

  /// Style pour les hints de formulaire
  static const TextStyle hintFormulaire = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.texteSecondaire,
    height: 1.5,
  );

  // === ÉTATS SPÉCIAUX ===
  /// Style pour les messages d'erreur
  static const TextStyle erreur = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.erreur,
    height: 1.4,
  );

  /// Style pour les liens
  static const TextStyle lien = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: CouleursApplication.primaire,
    decoration: TextDecoration.underline,
    height: 1.5,
  );

  /// Style pour les badges/étiquettes
  static const TextStyle badge = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
} 