import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/transcription_repository.dart';
import 'dependency_providers.dart';

/// État de la transcription
class TranscriptionState {
  final bool isTranscribing;
  final bool isGeneratingTitle;
  final String? result;
  final String? generatedTitle;
  final String? errorMessage;
  final double? progress; // Optionnel : pour la barre de progression

  const TranscriptionState({
    this.isTranscribing = false,
    this.isGeneratingTitle = false,
    this.result,
    this.generatedTitle,
    this.errorMessage,
    this.progress,
  });

  TranscriptionState copyWith({
    bool? isTranscribing,
    bool? isGeneratingTitle,
    String? result,
    String? generatedTitle,
    String? errorMessage,
    double? progress,
  }) {
    return TranscriptionState(
      isTranscribing: isTranscribing ?? this.isTranscribing,
      isGeneratingTitle: isGeneratingTitle ?? this.isGeneratingTitle,
      result: result ?? this.result,
      generatedTitle: generatedTitle ?? this.generatedTitle,
      errorMessage: errorMessage,
      progress: progress,
    );
  }

  /// Indique si une opération est en cours (transcription ou génération titre)
  bool get isBusy => isTranscribing || isGeneratingTitle;

  /// Indique si la transcription est complète avec succès
  bool get isComplete => result != null && !isBusy && errorMessage == null;

  /// Indique si une erreur s'est produite
  bool get hasError => errorMessage != null;
}

/// StateNotifier pour gérer la transcription avec injection de dépendances
/// 
/// TODO: Écrire des tests unitaires pour TranscriptionNotifier
/// - Test avec mock de TranscriptionRepository
/// - Test de gestion d'erreurs de transcription
/// - Test de génération de titre automatique et manuelle
/// - Test de mise à jour du résultat et du titre
/// - Test d'annulation de transcription en cours
class TranscriptionNotifier extends StateNotifier<TranscriptionState> {
  final TranscriptionRepository _repository;

  TranscriptionNotifier(this._repository) : super(const TranscriptionState());

  /// Lance la transcription d'un fichier audio
  Future<void> transcribeAudio(String filePath) async {
    try {
      // Réinitialisation et début de transcription
      state = state.copyWith(
        isTranscribing: true,
        errorMessage: null,
        result: null,
        generatedTitle: null,
        progress: 0.0,
      );

      // Simulation du progrès (optionnel)
      state = state.copyWith(progress: 0.3);

      // Appel de l'API de transcription
      final transcriptionResult = await _repository.transcribeAudio(filePath);

      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état
      // Évite les mises à jour après dispose ou navigation
      if (!mounted) return;

      // Transcription terminée
      state = state.copyWith(
        isTranscribing: false,
        result: transcriptionResult,
        progress: 1.0,
      );

      // Génération automatique du titre si la transcription a réussi
      if (transcriptionResult.isNotEmpty) {
        await _generateTitle(transcriptionResult);
      }

    } catch (e) {
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'erreur
      // Évite les crash lors d'erreurs après dispose
      if (!mounted) return;
      
      state = state.copyWith(
        isTranscribing: false,
        errorMessage: 'Erreur de transcription: ${e.toString()}',
        progress: null,
      );
    }
  }

  /// Génère un titre pour le texte transcrit
  Future<void> _generateTitle(String text) async {
    try {
      state = state.copyWith(
        isGeneratingTitle: true,
        errorMessage: null,
      );

      final title = await _repository.generateTitle(text);

      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour le titre
      // Évite les mises à jour de titre après dispose
      if (!mounted) return;

      state = state.copyWith(
        isGeneratingTitle: false,
        generatedTitle: title,
      );

    } catch (e) {
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état d'erreur
      // Évite les crash lors d'erreurs de génération après dispose
      if (!mounted) return;
      
      state = state.copyWith(
        isGeneratingTitle: false,
        generatedTitle: 'Titre non généré',
      );
      // Ne pas afficher l'erreur de génération de titre comme critique
      // car la transcription a réussi
    }
  }

  /// Génère manuellement un titre (appelé depuis l'UI)
  Future<void> generateTitle(String text) async {
    if (text.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Impossible de générer un titre pour un texte vide',
      );
      return;
    }

    await _generateTitle(text);
  }

  /// Met à jour le résultat de transcription (édition manuelle)
  void updateResult(String newResult) {
    state = state.copyWith(
      result: newResult,
      errorMessage: null,
    );
  }

  /// Met à jour le titre généré (édition manuelle)
  void updateTitle(String newTitle) {
    state = state.copyWith(
      generatedTitle: newTitle,
      errorMessage: null,
    );
  }

  /// Réinitialise l'état de transcription
  void reset() {
    state = const TranscriptionState();
  }

  /// Efface les erreurs
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Arrête une transcription en cours (si possible)
  void cancelTranscription() {
    if (state.isTranscribing || state.isGeneratingTitle) {
      state = state.copyWith(
        isTranscribing: false,
        isGeneratingTitle: false,
        errorMessage: 'Opération annulée par l\'utilisateur',
      );
    }
  }
}

/// Provider pour la transcription avec injection de dépendances
final transcriptionProvider = StateNotifierProvider<TranscriptionNotifier, TranscriptionState>((ref) {
  final transcriptionRepository = ref.watch(transcriptionRepositoryProvider);
  return TranscriptionNotifier(transcriptionRepository);
}); 