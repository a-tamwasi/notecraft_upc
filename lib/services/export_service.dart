import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../repositories/export_repository.dart';
import '../src/utils/error_handler.dart';

/// Service pour gérer l'export des transcriptions
/// Centralise la logique d'export en PDF et TXT
/// 
/// TODO: Écrire des tests unitaires pour ExportService
/// - Test d'export TXT avec texte valide et vide
/// - Test d'export PDF avec texte valide et vide  
/// - Test de gestion d'erreurs (permission refusée, espace insuffisant)
/// - Test de formatage des noms de fichiers avec timestamp
/// - Mock de FileSaver pour tests isolés
class ExportService implements ExportRepository {
  // --- //
  // 1. PROPRIÉTÉS PRIVÉES
  // --- //
  
  // --- //
  // 2. EXPORT EN FORMAT TXT
  // --- //
  
  /// Exporte la transcription au format TXT
  /// 
  /// [transcription] Le texte à exporter
  /// [ctx] Le contexte pour afficher les messages utilisateur
  /// 
  /// Retourne un Future qui se termine quand l'export est fini
  Future<void> exporterTxt(String transcription, BuildContext ctx) async {
    if (transcription.isEmpty) {
      if (ctx.mounted) {
        showError(ctx, 'Aucune transcription à exporter');
      }
      return;
    }

    try {
      // Conversion du texte en bytes UTF-8
      final Uint8List bytes = Uint8List.fromList(utf8.encode(transcription));
      
      // Génération du nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final nomFichier = 'transcription_${_formaterTimestamp(timestamp)}.txt';
      
      // Sauvegarde du fichier
      await FileSaver.instance.saveAs(
        name: nomFichier,
        bytes: bytes,
        ext: 'txt',
        mimeType: MimeType.text,
      );
      
      // Message de confirmation
      if (ctx.mounted) {
        showSuccess(ctx, 'Transcription exportée avec succès : $nomFichier');
      }
      
      debugPrint('Export TXT réussi : $nomFichier');
      
    } catch (e) {
      debugPrint('Erreur lors de l\'export TXT : $e');
      if (ctx.mounted) {
        showError(ctx, 'Erreur lors de l\'export TXT : $e');
      }
    }
  }

  // --- //
  // 3. EXPORT EN FORMAT PDF
  // --- //
  
  /// Exporte la transcription au format PDF
  /// 
  /// [transcription] Le texte à exporter
  /// [ctx] Le contexte pour afficher les messages utilisateur
  /// 
  /// Retourne un Future qui se termine quand l'export est fini
  Future<void> exporterPdf(String transcription, BuildContext ctx) async {
    if (transcription.isEmpty) {
      if (ctx.mounted) {
        showError(ctx, 'Aucune transcription à exporter');
      }
      return;
    }

    try {
      // Génération du nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final nomFichier = 'transcription_${_formaterTimestamp(timestamp)}';
      
      // Génération du PDF via le service dédié
      final cheminFichier = await PdfService.exporterTranscriptionPdf(
        transcription: transcription,
        fileName: nomFichier,
      );
      
      // Lecture du fichier PDF généré
      final file = File(cheminFichier);
      final pdfBytes = await file.readAsBytes();
      
      // Sauvegarde du fichier PDF via FileSaver
      await FileSaver.instance.saveAs(
        name: '$nomFichier.pdf',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      
      // Message de confirmation
      if (ctx.mounted) {
        showSuccess(ctx, 'PDF généré avec succès : $nomFichier');
      }
      
      debugPrint('Export PDF réussi : $nomFichier');
      
    } catch (e) {
      debugPrint('Erreur lors de l\'export PDF : $e');
      if (ctx.mounted) {
        showError(ctx, 'Erreur lors de l\'export PDF : $e');
      }
    }
  }

  // --- //
  // 4. MÉTHODES UTILITAIRES PRIVÉES
  // --- //
  
  /// Formate un timestamp pour les noms de fichiers
  /// Format : AAAAMMJJ_HHMMSS
  String _formaterTimestamp(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}_'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
  
  // L'affichage des messages est maintenant géré par le gestionnaire d'erreurs centralisé

  // --- //
  // 5. IMPLÉMENTATION DE L'INTERFACE ExportRepository
  // --- //
  
  @override
  Future<bool> exportToTxt(String text, BuildContext context) async {
    try {
      await exporterTxt(text, context);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> exportToPdf(String text, BuildContext context) async {
    try {
      await exporterPdf(text, context);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  bool canExport(String text) {
    return text.trim().isNotEmpty;
  }
  
  @override
  int getTextSize(String text) {
    return utf8.encode(text).length;
  }
  
  @override
  String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  // --- //
  // 6. MÉTHODES PUBLIQUES UTILITAIRES (rétrocompatibilité)
  // --- //
  
  /// Vérifie si une transcription peut être exportée (rétrocompatibilité)
  bool peutExporter(String? transcription) {
    return transcription != null && canExport(transcription);
  }
  
  /// Obtient la taille estimée d'un export TXT (rétrocompatibilité)
  int obtenirTailleTxt(String transcription) {
    return getTextSize(transcription);
  }
  
  /// Formate la taille d'un fichier pour l'affichage (rétrocompatibilité)
  String formaterTaille(int bytes) {
    return formatSize(bytes);
  }
}

// L'énumération MessageType n'est plus nécessaire avec le gestionnaire d'erreurs centralisé 