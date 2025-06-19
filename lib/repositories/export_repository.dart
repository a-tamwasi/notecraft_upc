import 'package:flutter/material.dart';

/// Interface abstraite pour l'export de transcriptions
/// Permet de mocker facilement pour les tests unitaires
abstract class ExportRepository {
  /// Exporte le texte au format TXT
  /// [text] : le texte à exporter
  /// [context] : contexte Flutter pour afficher les messages
  /// Retourne true si l'export a réussi
  Future<bool> exportToTxt(String text, BuildContext context);
  
  /// Exporte le texte au format PDF
  /// [text] : le texte à exporter
  /// [context] : contexte Flutter pour afficher les messages
  /// Retourne true si l'export a réussi
  Future<bool> exportToPdf(String text, BuildContext context);
  
  /// Vérifie si le texte peut être exporté (non vide, etc.)
  /// [text] : le texte à vérifier
  /// Retourne true si l'export est possible
  bool canExport(String text);
  
  /// Obtient la taille estimée du fichier TXT en octets
  /// [text] : le texte à analyser
  /// Retourne la taille en octets
  int getTextSize(String text);
  
  /// Formate la taille en octets vers une chaîne lisible (KB, MB, etc.)
  /// [bytes] : nombre d'octets
  /// Retourne une chaîne formatée comme "1.2 KB"
  String formatSize(int bytes);
} 