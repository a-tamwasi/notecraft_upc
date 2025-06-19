import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audioplayer;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/utils/error_handler.dart';
import '../../controllers/navigation_notifier.dart';
import '../../services/credit_service.dart';
import '../../data/database/database_service.dart';
import '../../models/note_model.dart';
import '../../notifiers/history_notifier.dart';
import '../../widgets/section_rappel_credit.dart';
import '../../widgets/section_enregistrement.dart';
import '../../widgets/section_transcription.dart';
import '../../providers/audio_recorder_provider.dart';
import '../../providers/transcription_provider.dart';
import '../../providers/dependency_providers.dart';
import 'package:intl/intl.dart';

/// Vue principale pour la transcription audio
/// Affiche l'interface utilisateur pour enregistrer ou importer des audios
class TranscriptionView extends ConsumerStatefulWidget {
  const TranscriptionView({Key? key}) : super(key: key);

  @override
  ConsumerState<TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends ConsumerState<TranscriptionView> {
  bool _isImporting = false;
  final TextEditingController _transcriptionController = TextEditingController();
  final audioplayer.AudioPlayer _audioPlayer = audioplayer.AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _transcriptionSectionKey = GlobalKey();
  
  // Note: ExportService est maintenant injecté via les providers

  @override
  void initState() {
    super.initState();
    // Écoute les changements du service de crédits pour reconstruire le widget.
    creditService.addListener(_onCreditsChanged);
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    // Cesse d'écouter les changements pour éviter les fuites de mémoire.
    creditService.removeListener(_onCreditsChanged);
    super.dispose();
  }

  // Déclenche une reconstruction du widget lorsque les crédits changent.
  void _onCreditsChanged() {
    // Vérifier que le widget est toujours monté avant d'appeler setState
    // Évite les erreurs si le widget a été dispose pendant une opération asynchrone
    if (!mounted) return;
    
    setState(() {
      // Le contenu du widget sera reconstruit avec les nouvelles valeurs du service.
    });
  }

  // Scroll automatiquement vers la section de transcription
  void _scrollToTranscriptionSection() {
    if (_transcriptionSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _transcriptionSectionKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Vérifie si l'utilisateur a suffisamment de crédits avant action
  bool _hasEnoughCredits() {
    if (creditService.remainingCreditSeconds <= 0) {
      _montrerAlerteCreditEpuise();
      return false;
    }
    return true;
  }

  /// Surveille l'épuisement des crédits pendant l'enregistrement
  void _monitorCreditsDuringRecording() {
    // Vérifier que le widget est toujours monté avant d'afficher des messages
    // Évite les tentatives d'affichage de SnackBar sur un widget disposé
    if (!mounted) return;
    
    final audioState = ref.read(audioRecorderProvider);
    if (audioState.secondesEcoulees >= creditService.remainingCreditSeconds) {
      ref.read(audioRecorderProvider.notifier).stopRecording();
      showWarning(context, 'Crédit de transcription épuisé. Enregistrement arrêté.');
    }
  }

  /// Détermine l'action à effectuer selon l'état actuel de l'enregistrement
  void _toggleRecording() async {
    if (!_hasEnoughCredits()) return;

    final audioNotifier = ref.read(audioRecorderProvider.notifier);
    final audioState = ref.read(audioRecorderProvider);

    if (audioState.isRecording && !audioState.isPaused) {
      // Mettre en pause l'enregistrement
      await audioNotifier.pauseRecording();
    } else if (audioState.isRecording && audioState.isPaused) {
      // Reprendre l'enregistrement
      await audioNotifier.resumeRecording();
    } else {
      // Commencer l'enregistrement
      await audioNotifier.startRecording();
      ref.read(transcriptionProvider.notifier).reset();
    }
  }

  /// Arrête l'enregistrement et lance la transcription
  Future<void> _arreterEnregistrement() async {
    final audioNotifier = ref.read(audioRecorderProvider.notifier);
    final audioState = ref.read(audioRecorderProvider);
    
    final dureeEnregistrement = await audioNotifier.stopRecording();
    
    if (dureeEnregistrement != null && audioState.lastRecordingPath != null) {
      // Lancer automatiquement la transcription
      await _transcribeAudio(audioState.lastRecordingPath!, dureeEnregistrement);
    }
  }

  /// Lance la transcription d'un fichier audio
  Future<void> _transcribeAudio(String filePath, int audioDurationInSeconds) async {
    if (!_hasEnoughCredits()) return;

    // Lancer la transcription via le provider
    await ref.read(transcriptionProvider.notifier).transcribeAudio(filePath);
    
    final transcriptionState = ref.read(transcriptionProvider);
    
    if (transcriptionState.isComplete && transcriptionState.result != null) {
      // Succès : déduire les crédits et mettre à jour l'UI
      creditService.deductCredits(audioDurationInSeconds);
      _transcriptionController.text = transcriptionState.result!;

      // Scroll automatiquement vers la section de transcription
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTranscriptionSection();
      });

      // Sauvegarder automatiquement la note
      await _sauvegarderAutomatiquementLaNote(
        titre: transcriptionState.generatedTitle ?? 'Transcription du ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        transcription: transcriptionState.result!,
        dureeEnregistrement: audioDurationInSeconds,
        cheminAudio: filePath,
      );
    } else if (transcriptionState.hasError) {
      // Vérifier que le widget est toujours monté avant d'afficher l'erreur
      // Évite les erreurs de SnackBar après navigation ou dispose du widget
      if (!mounted) return;
      
      // Erreur : afficher le message
      showError(context, transcriptionState.errorMessage!);
    }
  }

  /// Demande la permission d'accès au stockage/audio
  Future<bool> _requestStoragePermission() async {
    final permission = Permission.audio;
    var status = await permission.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  /// Importe et transcrit un fichier audio
  Future<void> _importAndUploadAudio() async {
    if (!await _requestStoragePermission()) return;

    setState(() => _isImporting = true);

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        
        // Obtenir la vraie durée du fichier audio
        int realDurationSeconds;
        try {
          final tempPlayer = audioplayer.AudioPlayer();
          await tempPlayer.setSourceDeviceFile(filePath);
          
          Duration? duration = await tempPlayer.getDuration();
          
          if (duration != null) {
            realDurationSeconds = duration.inSeconds;
          } else {
            // Fallback : estimation basée sur la taille
            final fileSizeInBytes = result.files.single.size;
            realDurationSeconds = (fileSizeInBytes / (1024 * 1024) * 60).round();
          }
          
          await tempPlayer.dispose();
          
        } catch (e) {
          // Fallback : estimation basée sur la taille du fichier
          final fileSizeInBytes = result.files.single.size;
          realDurationSeconds = (fileSizeInBytes / (1024 * 1024) * 60).round();
        }
        
        // Procéder à la transcription avec la vraie durée
        await _transcribeAudio(filePath, realDurationSeconds);
      }
    } catch (e) {
      if (mounted) {
        showError(context, 'Erreur lors de l\'import: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Surveiller les états via les providers
    final audioState = ref.watch(audioRecorderProvider);
    final transcriptionState = ref.watch(transcriptionProvider);
    
    // Surveiller l'épuisement des crédits pendant l'enregistrement
    ref.listen(audioRecorderProvider, (previous, current) {
      if (current.isRecording && !current.isPaused) {
        _monitorCreditsDuringRecording();
      }
    });

    // Écouter les changements de transcription pour mettre à jour le contrôleur
    ref.listen(transcriptionProvider, (previous, current) {
      if (current.result != null && current.result != _transcriptionController.text) {
        _transcriptionController.text = current.result!;
      }
    });

    // Obtenir la hauteur de la BottomNavigationBar pour éviter le chevauchement
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 
                         MediaQuery.of(context).padding.bottom + 
                         kBottomNavigationBarHeight + 
                         DimensionsApplication.paddingM;

    return Scaffold(
      backgroundColor: CouleursApplication.fondPrincipal,
      body: GestureDetector(
        onTap: () {
          // Ferme le clavier lorsqu'on clique en dehors des champs de texte
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: DimensionsApplication.paddingM,
              right: DimensionsApplication.paddingM,
              top: DimensionsApplication.paddingM,
              bottom: bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionRappelCredit(
                  creditSecondesRestantes: creditService.remainingCreditSeconds,
                  creditSecondesTotal: creditService.totalCreditSeconds,
                  onAcheterCredits: _acheterPlusDeCredits,
                ),
                const SizedBox(height: DimensionsApplication.margeSection),
                SectionEnregistrement(
                  estEnregistrement: audioState.isRecording,
                  estEnPause: audioState.isPaused,
                  estImportation: _isImporting,
                  estTranscription: transcriptionState.isTranscribing,
                  audioRecorderController: ref.read(audioRecorderControllerProvider),
                  onToggleEnregistrement: _toggleRecording,
                  onArreterEnregistrement: _arreterEnregistrement,
                  onImporterAudio: _importAndUploadAudio,
                ),
                const SizedBox(height: DimensionsApplication.margeSection),
                if (transcriptionState.result != null) 
                  SectionTranscription(
                    controleurTranscription: _transcriptionController,
                    cle: _transcriptionSectionKey,
                    onExporterPdf: () => _exporterPdf(context),
                    onExporterTxt: () => _exporterTxt(context),
                    onSauvegarder: _sauvegarderTranscription,
                    onSupprimer: _confirmerSuppression,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sauvegarde la transcription modifiée
  void _sauvegarderTranscription() {
    // Mettre à jour le provider avec le texte modifié
    ref.read(transcriptionProvider.notifier).updateResult(_transcriptionController.text);
    
    showSuccess(context, 'Transcription sauvegardée !');
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
                // Réinitialiser les providers
                ref.read(transcriptionProvider.notifier).reset();
                ref.read(audioRecorderProvider.notifier).reset();
                _transcriptionController.clear();
                showInfo(context, 'Transcription supprimée');
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Gère la navigation vers la page d'achat et la mise à jour des crédits
  Future<void> _acheterPlusDeCredits() async {
    // Met à jour la valeur du notificateur pour demander le changement vers l'onglet 3 (Abonnement).
    navigationNotifier.value = 3;
  }

  /// Affiche une alerte si le crédit est totalement épuisé
  void _montrerAlerteCreditEpuise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crédit épuisé'),
        content: const Text('Vous n\'avez plus de minutes de transcription. Veuillez en acheter pour continuer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acheterPlusDeCredits();
            },
            child: const Text('Acheter plus'),
          ),
        ],
      ),
    );
  }

  /// Exporte la transcription en PDF en utilisant le repository injecté
  Future<void> _exporterPdf(BuildContext context) async {
    final exportRepository = ref.read(exportRepositoryProvider);
    await exportRepository.exportToPdf(_transcriptionController.text, context);
  }

  /// Exporte la transcription en TXT en utilisant le repository injecté
  Future<void> _exporterTxt(BuildContext context) async {
    final exportRepository = ref.read(exportRepositoryProvider);
    await exportRepository.exportToTxt(_transcriptionController.text, context);
  }

  /// Sauvegarde automatiquement la note dans la base de données
  Future<void> _sauvegarderAutomatiquementLaNote({
    required String titre,
    required String transcription,
    required int dureeEnregistrement,
    required String cheminAudio,
  }) async {
    try {
      final nouvelleNote = Note(
        titre: titre,
        contenu: transcription,
        dateCreation: DateTime.now(),
        duree: dureeEnregistrement,
        cheminAudio: cheminAudio,
        langue: 'fr-FR',
      );

      await DatabaseService.instance.create(nouvelleNote);
      print('Note sauvegardée avec succès dans la base de données.');

      // Notifier la page d'historique qu'une nouvelle note a été ajoutée
      historyNotifier.notifyHistoryChanged();

    } catch (e) {
      print('Erreur lors de la sauvegarde automatique de la note: $e');
      
      // Vérifier que le widget est toujours monté avant d'afficher l'erreur
      // Évite les crashes lors de la sauvegarde après navigation
      if (!mounted) return;
      
      showError(context, 'Erreur lors de la sauvegarde de la note: $e');
    }
  }
} 