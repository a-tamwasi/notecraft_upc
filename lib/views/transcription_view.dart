import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/openai_service.dart';
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
  bool _isImporting = false;
  bool _isTranscribing = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  AudioRecorder? _recorder;
  String? _recordingPath;
  String? _transcriptionResult;
  final OpenAIService _openAIService = OpenAIService();

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

    if (_isRecording) {
      // Arrêter l'enregistrement
      await _stopRecording();
    } else {
      // Commencer l'enregistrement
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      _recordingPath = await _getRecordingPath();
      
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _secondsElapsed = 0;
        _transcriptionResult = null;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du démarrage de l\'enregistrement: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stop();
      _timer?.cancel();
      
      setState(() {
        _isRecording = false;
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

  Future<void> _transcribeAudio(String filePath) async {
    setState(() => _isTranscribing = true);

    try {
      final transcription = await _openAIService.transcrireAudio(filePath);
      
      setState(() {
        _transcriptionResult = transcription;
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
    return Scaffold(
      backgroundColor: CouleursApplication.fondPrincipal,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionsApplication.paddingM),
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
            ElevatedButton.icon(
              onPressed: (_isImporting || _isTranscribing) ? null : _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
              label: Text(
                _isRecording ? 'Stop Recording' : 'Record Audio',
                style: StylesTexte.corps.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : CouleursApplication.primaire,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DimensionsApplication.radiusXL),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: DimensionsApplication.paddingM,
                  horizontal: DimensionsApplication.paddingL,
                ),
              ),
            ),
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
            const SizedBox(height: DimensionsApplication.paddingM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DimensionsApplication.paddingM),
              decoration: BoxDecoration(
                color: CouleursApplication.fondPrincipal,
                borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
                border: Border.all(color: CouleursApplication.bordure),
              ),
              child: Text(
                _transcriptionResult!,
                style: StylesTexte.corps,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le bouton d'importation personnalisé
  Widget _buildImportButton() {
    return Opacity(
      opacity: _isRecording ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CouleursApplication.primaire, CouleursApplication.secondaire],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: CouleursApplication.fondSecondaire,
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL - 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isRecording ? null : _importAndUploadAudio,
                borderRadius: BorderRadius.circular(DimensionsApplication.radiusXL - 1.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DimensionsApplication.paddingS,
                    horizontal: DimensionsApplication.paddingM,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        color: CouleursApplication.primaire,
                      ),
                      const SizedBox(width: DimensionsApplication.paddingS),
                      Text(
                        'Import Audio File',
                        style: StylesTexte.corps.copyWith(color: CouleursApplication.primaire),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 