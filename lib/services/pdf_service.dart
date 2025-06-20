import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// Service pour l'exportation des transcriptions en PDF
class PdfService {
  /// Exporte une transcription en fichier PDF
  /// 
  /// [transcription] - Le texte de la transcription à exporter
  /// [fileName] - Nom du fichier (optionnel, génère automatiquement si null)
  /// 
  /// Retourne le chemin du fichier PDF créé
  static Future<String> exporterTranscriptionPdf({
    required String transcription,
    String? fileName,
  }) async {
    // Création du document PDF
    final pdf = pw.Document();

    // Génération du nom de fichier si non fourni
    fileName ??= 'transcription_${DateTime.now().millisecondsSinceEpoch}';
    if (!fileName.endsWith('.pdf')) {
      fileName += '.pdf';
    }

    // Ajout de la page avec le contenu
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête du document
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'NoteCraft - Transcription Audio',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    _formatDate(DateTime.now()),
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Ligne de séparation
            pw.Divider(color: PdfColors.grey400),
            
            pw.SizedBox(height: 20),
            
            // Titre de la section
            pw.Text(
              'Contenu de la transcription',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            
            pw.SizedBox(height: 15),
            
            // Contenu de la transcription avec pagination automatique
            ...(_buildTranscriptionContent(transcription)),
            
            pw.SizedBox(height: 30),
            
            // Informations supplémentaires
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Informations du document',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Date de création: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Nombre de caractères: ${transcription.length}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Généré par: NoteCraft App',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} sur ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          );
        },
      ),
    );

    // Sauvegarde du fichier
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    
    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);

    return filePath;
  }

  /// Construit le contenu de la transcription avec pagination automatique
  static List<pw.Widget> _buildTranscriptionContent(String transcription) {
    if (transcription.isEmpty) {
      return [
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Text(
            'Aucune transcription disponible.',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    // Diviser le texte en paragraphes pour une meilleure pagination
    final paragraphs = transcription.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    
    List<pw.Widget> widgets = [];
    
    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      
      widgets.add(
        pw.Paragraph(
          text: paragraph,
          style: pw.TextStyle(
            fontSize: 12,
            lineSpacing: 1.5,
            color: PdfColors.grey800,
          ),
          textAlign: pw.TextAlign.justify,
          margin: const pw.EdgeInsets.only(bottom: 12),
        ),
      );
      
      // Ajouter un espace entre les paragraphes
      if (i < paragraphs.length - 1) {
        widgets.add(pw.SizedBox(height: 8));
      }
    }
    
    // Si pas de paragraphes détectés, traiter comme un seul bloc
    if (widgets.isEmpty) {
      widgets.add(
        pw.Paragraph(
          text: transcription,
          style: pw.TextStyle(
            fontSize: 12,
            lineSpacing: 1.5,
            color: PdfColors.grey800,
          ),
          textAlign: pw.TextAlign.justify,
        ),
      );
    }
    
    return widgets;
  }

  /// Formate une date en français
  static String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Ouvre le fichier PDF avec l'application par défaut du système
  /// 
  /// [filePath] - Chemin vers le fichier PDF à ouvrir
  static Future<void> ouvrirPdf(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      // Sur Android/iOS, vous pourriez utiliser un package comme open_file
      // Pour l'instant, on affiche juste le chemin
      print('📄 PDF sauvegardé: $filePath');
    }
  }
} 