import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/openai_service.dart';
import '../services/pdf_service.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';
import '../src/constants/styles_texte.dart';

/// Vue principale pour la transcription audio
/// Affiche l'interface utilisateur pour enregistrer ou importer des audios
class TranscriptionView extends StatefulWidget {
  const TranscriptionView({Key? key}) : super(key: key);

  @override
  _TranscriptionViewState createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isImporting = false;
  bool _isTranscribing = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  AudioRecorder? _recorder;
  String? _recordingPath;
  String? _transcriptionResult;
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _transcriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    
    _recorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder?.dispose();
    _transcriptionController.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<bool> _requestStoragePermission() async {
    // Sur Android 13+, on demande la permission audio spécifique.
    // Sinon, on demande le stockage général.
    final permission = Permission.audio;
    var status = await permission.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<String> _getRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.m4a';
  }

  void _toggleRecording() async {
    if (!await _requestMicrophonePermission()) return;

    if (_isRecording && !_isPaused) {
      // Mettre en pause l'enregistrement
      await _pauseRecording();
    } else if (_isRecording && _isPaused) {
      // Reprendre l'enregistrement
      await _resumeRecording();
    } else {
      // Commencer l'enregistrement
      await _startRecording();
    }
  }

  void _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      await _recorder!.stop();
      _timer?.cancel();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
        // Réinitialiser le chronomètre à zéro après arrêt
        _secondsElapsed = 0;
      });

      // Lancer automatiquement la transcription
      if (_recordingPath != null) {
        await _transcribeAudio(_recordingPath!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'arrêt de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      _recordingPath = await _getRecordingPath();
      
      // Configuration optimisée pour la transcription
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC-LC optimal pour Whisper
          bitRate: 64000, // Réduit de 128k à 64k (suffisant pour la parole)
          sampleRate: 16000, // Réduit de 44.1k à 16k (optimal pour Whisper)
          numChannels: 1, // Mono au lieu de stéréo (plus petit fichier)
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _secondsElapsed = 0;
        _transcriptionResult = null;
      });

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du démarrage de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder!.pause();
      _timer?.cancel();
      
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la pause de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder!.resume();
      
      setState(() {
        _isPaused = false;
      });

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la reprise de l\'enregistrement: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  Future<void> _transcribeAudio(String filePath) async {
    setState(() => _isTranscribing = true);

    try {
      print('🎵 Début de la transcription du fichier: $filePath');
      final transcription = await _openAIService.transcrireAudio(filePath);
      
      setState(() {
        _transcriptionResult = transcription;
        _transcriptionController.text = transcription;
        // Réinitialiser le chronomètre à zéro après transcription réussie
        _secondsElapsed = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription terminée !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de transcription: $e')),
      );
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  Future<void> _importAndUploadAudio() async {
    if (!await _requestStoragePermission()) return;

    setState(() => _isImporting = true);

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        await _transcribeAudio(filePath);
      } else {
        print("Aucun fichier sélectionné.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir la hauteur de la BottomNavigationBar pour éviter le chevauchement
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 
                         MediaQuery.of(context).padding.bottom + 
                         kBottomNavigationBarHeight + 
                         DimensionsApplication.paddingM;

    return Scaffold(
      backgroundColor: CouleursApplication.fondPrincipal,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: DimensionsApplication.paddingM,
            right: DimensionsApplication.paddingM,
            top: DimensionsApplication.paddingM,
            bottom: bottomPadding, // Padding dynamique pour éviter le chevauchement
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _construireSectionEnregistrement(),
              const SizedBox(height: DimensionsApplication.margeSection),
              if (_transcriptionResult != null) _construireSectionTranscription(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la section d'enregistrement audio
  Widget _construireSectionEnregistrement() {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: DimensionsApplication.paddingXL,
            horizontal: DimensionsApplication.paddingL),
        child: Column(
          children: [
            // Bouton principal (Enregistrer/Pause/Reprendre)
            ElevatedButton.icon(
              onPressed: (_isImporting || _isTranscribing) ? null : _toggleRecording,
              icon: Icon(
                _isRecording 
                  ? (_isPaused ? Icons.play_arrow : Icons.pause)
                  : Icons.mic, 
                color: Colors.white
              ),
              label: Text(
                _isRecording 
                  ? (_isPaused ? 'Reprendre l\'enregistrement' : 'Mettre en pause')
                  : 'Enregistrer Audio',
                style: StylesTexte.corps.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording 
                  ? (_isPaused ? Colors.green : Colors.orange)
                  : CouleursApplication.primaire,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: DimensionsApplication.paddingM,
                  horizontal: DimensionsApplication.paddingL,
                ),
              ),
            ),
            // Bouton d'arrêt (visible seulement pendant l'enregistrement)
            if (_isRecording) ...[
              const SizedBox(height: DimensionsApplication.paddingM),
              ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: Text(
                  'Arrêter l\'enregistrement',
                  style: StylesTexte.corps.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: DimensionsApplication.paddingM,
                    horizontal: DimensionsApplication.paddingL,
                  ),
                ),
              ),
            ],
            const SizedBox(height: DimensionsApplication.margeGrande),
            Text(
              _formatDuration(_secondsElapsed),
              style: StylesTexte.titrePrincipal.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            if (_isTranscribing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: DimensionsApplication.paddingM),
                  Text('Transcription en cours...'),
                ],
              )
            else if (_isImporting)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: DimensionsApplication.paddingM),
                  Text('Importation en cours...'),
                ],
              )
            else
              _buildImportButton(),
          ],
        ),
      ),
    );
  }

  Widget _construireSectionTranscription() {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et menu d'actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.text_snippet,
                      color: CouleursApplication.primaire,
                      size: DimensionsApplication.iconeL,
                    ),
                    const SizedBox(width: DimensionsApplication.paddingS),
                    Text(
                      'Transcription',
                      style: StylesTexte.titreSection,
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: CouleursApplication.primaire,
                    size: 24,
                  ),
                  tooltip: 'Options',
                  color: Colors.white.withOpacity(0.95),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (String value) async {
                    switch (value) {
                      case 'exporter_pdf':
                        await _exporterPdf();
                        break;
                      case 'exporter_txt':
                        await _exporterTxt();
                        break;
                      case 'sauvegarder':
                        setState(() {
                          _transcriptionResult = _transcriptionController.text;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transcription sauvegardée !')),
                        );
                        break;
                      case 'supprimer':
                        _confirmerSuppression();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'sauvegarder',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.save, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Text('Sauvegarder', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'exporter_pdf',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Exporter en PDF', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'exporter_txt',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.text_snippet, color: Colors.green, size: 20),
                            SizedBox(width: 12),
                            Text('Exporter en TXT', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'supprimer',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Supprimer', style: TextStyle(fontSize: 15, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DimensionsApplication.paddingM),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 120, // Hauteur minimale pour assurer la visibilité
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Maximum 40% de l'écran
              ),
              decoration: BoxDecoration(
                color: CouleursApplication.fondPrincipal,
                borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
                border: Border.all(color: CouleursApplication.bordure),
              ),
              child: TextFormField(
                controller: _transcriptionController,
                maxLines: null,
                minLines: 5,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight + 20,
                ),
                decoration: InputDecoration(
                  hintText: 'Votre transcription apparaîtra ici. Vous pouvez la modifier...',
                  hintStyle: StylesTexte.corpsSecondaire,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(DimensionsApplication.paddingM),
                ),
                style: StylesTexte.corps,
                onChanged: (value) {
                  // Optionnel : vous pouvez ajouter une logique ici si nécessaire
                },
              ),
            ),
            const SizedBox(height: DimensionsApplication.paddingS),
            Text(
              'Conseil : Vous pouvez modifier le texte directement dans le champ ci-dessus.',
              style: StylesTexte.corpsPetit.copyWith(
                color: CouleursApplication.texteSecondaire,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

    /// Construit le bouton d'importation harmonisé
  Widget _buildImportButton() {
    return ElevatedButton.icon(
      onPressed: (_isRecording || _isTranscribing) ? null : _importAndUploadAudio,
      icon: const Icon(Icons.upload_file, color: Colors.white),
      label: Text(
        'Importer un fichier audio',
        style: StylesTexte.corps.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApplication.secondaire,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: DimensionsApplication.paddingM,
          horizontal: DimensionsApplication.paddingL,
        ),
      ),
    );
  }

  /// Confirme la suppression de la transcription
  void _confirmerSuppression() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette transcription ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _transcriptionResult = null;
                  _transcriptionController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transcription supprimée')),
                );
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Exporte la transcription en fichier TXT
  Future<void> _exporterTxt() async {
    if (_transcriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transcription à exporter !')),
      );
      return;
    }

    try {
      // Générer un nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_$formattedDate.txt';

      // Créer le contenu du fichier avec métadonnées
      final content = '''NoteCraft - Transcription Audio
Date de création: ${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}
Nombre de caractères: ${_transcriptionController.text.length}
Nombre de mots: ${_transcriptionController.text.split(' ').where((word) => word.isNotEmpty).length}

=====================================
CONTENU DE LA TRANSCRIPTION
=====================================

${_transcriptionController.text}

=====================================
Généré par NoteCraft App
=====================================''';

      // Convertir le contenu en bytes
      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      // Utiliser file_saver pour permettre à l'utilisateur de choisir l'emplacement
      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        ext: 'txt',
        mimeType: MimeType.text,
      );

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      if (filePath != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Fichier TXT exporté avec succès !'),
                Text('📁 $fileName'),
                Text('📊 Taille: ${(bytes.length / 1024).toStringAsFixed(1)} KB'),
                Text('📍 Sauvegardé à l\'emplacement choisi'),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Voir le chemin',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Fichier sauvegardé'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du fichier: $fileName'),
                        const SizedBox(height: 8),
                        const Text('Emplacement:'),
                        SelectableText(filePath),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // L'utilisateur a annulé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportation annulée par l\'utilisateur')),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'exportation TXT: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      print('Erreur exportation TXT: $e');
    }
  }

  /// Exporte la transcription en PDF
  Future<void> _exporterPdf() async {
    if (_transcriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transcription à exporter !')),
      );
      return;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Génération du PDF...'),
            ],
          ),
        ),
      );

      // Générer un nom de fichier avec timestamp
      final timestamp = DateTime.now();
      final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}_${timestamp.hour.toString().padLeft(2, '0')}h${timestamp.minute.toString().padLeft(2, '0')}';
      final fileName = 'NoteCraft_Transcription_$formattedDate.pdf';

      // Générer le PDF en mémoire
      final String tempFilePath = await PdfService.exporterTranscriptionPdf(
        transcription: _transcriptionController.text,
        fileName: fileName,
      );

      // Lire le fichier PDF généré
      final File tempFile = File(tempFilePath);
      final Uint8List pdfBytes = await tempFile.readAsBytes();

      // Mettre à jour le message de chargement
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sélection de l\'emplacement...'),
            ],
          ),
        ),
      );

      // Utiliser file_saver pour permettre à l'utilisateur de choisir l'emplacement
      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      // Supprimer le fichier temporaire
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      if (filePath != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ PDF exporté avec succès !'),
                Text('📁 $fileName'),
                Text('📊 Taille: ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB'),
                Text('📍 Sauvegardé à l\'emplacement choisi'),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Voir le chemin',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('PDF sauvegardé'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du fichier: $fileName'),
                        const SizedBox(height: 8),
                        const Text('Emplacement:'),
                        SelectableText(filePath),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // L'utilisateur a annulé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportation annulée par l\'utilisateur')),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'exportation PDF: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      print('Erreur exportation PDF: $e');
    }
  }
} 