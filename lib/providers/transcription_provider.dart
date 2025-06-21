import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/transcription_repository.dart';
import '../services/hybrid_transcription_service.dart';
import 'dependency_providers.dart';

/// État de la transcription
class TranscriptionState {
  final bool isTranscribing;
  final bool isGeneratingTitle;
  final bool isEnhancing; // Nouveau : indique si l'amélioration est en cours
  final String? result;
  final String? generatedTitle;
  final String? enhancedResult; // Nouveau : résultat amélioré par l'IA
  final String? errorMessage;
  final double? progress; // Optionnel : pour la barre de progression
  final bool showEnhanced; // Nouveau : indique quelle version afficher

  const TranscriptionState({
    this.isTranscribing = false,
    this.isGeneratingTitle = false,
    this.isEnhancing = false,
    this.result,
    this.generatedTitle,
    this.enhancedResult,
    this.errorMessage,
    this.progress,
    this.showEnhanced = false,
  });

  TranscriptionState copyWith({
    bool? isTranscribing,
    bool? isGeneratingTitle,
    bool? isEnhancing,
    String? result,
    String? generatedTitle,
    String? enhancedResult,
    String? errorMessage,
    double? progress,
    bool? showEnhanced,
  }) {
    return TranscriptionState(
      isTranscribing: isTranscribing ?? this.isTranscribing,
      isGeneratingTitle: isGeneratingTitle ?? this.isGeneratingTitle,
      isEnhancing: isEnhancing ?? this.isEnhancing,
      result: result ?? this.result,
      generatedTitle: generatedTitle ?? this.generatedTitle,
      enhancedResult: enhancedResult ?? this.enhancedResult,
      errorMessage: errorMessage,
      progress: progress,
      showEnhanced: showEnhanced ?? this.showEnhanced,
    );
  }

  /// Indique si une opération est en cours (transcription, génération titre ou amélioration)
  bool get isBusy => isTranscribing || isGeneratingTitle || isEnhancing;

  /// Indique si la transcription est complète avec succès
  bool get isComplete => result != null && !isBusy && errorMessage == null;

  /// Indique si une erreur s'est produite
  bool get hasError => errorMessage != null;

  /// Retourne le texte à afficher selon le mode sélectionné
  String get displayText => (showEnhanced && enhancedResult != null) ? enhancedResult! : (result ?? '');
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

  /// Lance la transcription d'un fichier audio avec optimisations de performance
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

      // Mise à jour du progrès pour le feedback utilisateur
      state = state.copyWith(progress: 0.1);

      // Appel de l'API de transcription (optimisée avec nova-2)
      final transcriptionResult = await _repository.transcribeAudio(filePath);

      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état
      if (!mounted) return;

      // Transcription terminée - mise à jour immédiate pour l'utilisateur
      state = state.copyWith(
        isTranscribing: false,
        result: transcriptionResult,
        progress: 0.8, // 80% - transcription terminée
      );

      // Génération du titre EN PARALLÈLE (non bloquant pour l'affichage du résultat)
      if (transcriptionResult.isNotEmpty) {
        // Lancer la génération de titre en arrière-plan sans bloquer l'affichage
        _generateTitleAsync(transcriptionResult);
      }

      // Finalisation
      state = state.copyWith(progress: 1.0);

    } catch (e) {
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'erreur
      if (!mounted) return;
      
      state = state.copyWith(
        isTranscribing: false,
        errorMessage: 'Erreur de transcription: ${e.toString()}',
        progress: null,
      );
    }
  }

  /// Lance la transcription ULTRA-RAPIDE d'un fichier audio
  /// Optimisée pour la vitesse maximale, avec moins de fonctionnalités de formatage
  Future<void> transcribeAudioFast(String filePath) async {
    try {
      // Réinitialisation et début de transcription
      state = state.copyWith(
        isTranscribing: true,
        errorMessage: null,
        result: null,
        generatedTitle: null,
        progress: 0.0,
      );

      // Utiliser la méthode ultra-rapide si disponible
      late String transcriptionResult;
      if (_repository is HybridTranscriptionService) {
        final hybrid = _repository;
        transcriptionResult = await hybrid.transcribeAudioFast(filePath);
      } else {
        // Fallback sur la méthode normale
        transcriptionResult = await _repository.transcribeAudio(filePath);
      }

      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état
      if (!mounted) return;

      // Transcription terminée - mise à jour immédiate pour l'utilisateur
      state = state.copyWith(
        isTranscribing: false,
        result: transcriptionResult,
        progress: 0.9, // 90% - transcription ultra-rapide terminée
      );

      // Génération du titre EN PARALLÈLE (non bloquant)
      if (transcriptionResult.isNotEmpty) {
        _generateTitleAsync(transcriptionResult);
      }

      // Finalisation
      state = state.copyWith(progress: 1.0);

    } catch (e) {
      if (!mounted) return;
      
      state = state.copyWith(
        isTranscribing: false,
        errorMessage: 'Erreur de transcription ultra-rapide: ${e.toString()}',
        progress: null,
      );
    }
  }

  /// Génère un titre de manière asynchrone sans bloquer l'affichage du résultat
  void _generateTitleAsync(String text) async {
    try {
      state = state.copyWith(
        isGeneratingTitle: true,
        errorMessage: null,
      );

      final title = await _repository.generateTitle(text);

      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour le titre
      if (!mounted) return;

      state = state.copyWith(
        isGeneratingTitle: false,
        generatedTitle: title,
      );

    } catch (e) {
      // Vérifier si le StateNotifier est toujours monté avant de mettre à jour l'état d'erreur
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

    _generateTitleAsync(text);
  }

  /// Met à jour le résultat de transcription (édition manuelle)
  void updateResult(String newResult) {
    if (state.showEnhanced && state.enhancedResult != null) {
      // Si on affiche la version améliorée, mettre à jour celle-ci
      state = state.copyWith(
        enhancedResult: newResult,
        errorMessage: null,
      );
    } else {
      // Sinon, mettre à jour la version brute
      state = state.copyWith(
        result: newResult,
        errorMessage: null,
      );
    }
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

  /// Améliore la transcription en utilisant l'IA
  Future<void> enhanceTranscription() async {
    if (state.result == null || state.result!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Aucune transcription à améliorer',
      );
      return;
    }

    try {
      state = state.copyWith(
        isEnhancing: true,
        errorMessage: null,
      );

      final enhancedText = await _repository.enhanceTranscription(state.result!);

      if (!mounted) return;

      state = state.copyWith(
        isEnhancing: false,
        enhancedResult: enhancedText,
        showEnhanced: true, // Basculer automatiquement vers la version améliorée
      );

    } catch (e) {
      if (!mounted) return;
      
      state = state.copyWith(
        isEnhancing: false,
        errorMessage: 'Erreur d\'amélioration: ${e.toString()}',
      );
    }
  }

  /// Bascule entre la version brute et la version améliorée
  void toggleDisplayMode() {
    if (state.enhancedResult != null) {
      state = state.copyWith(
        showEnhanced: !state.showEnhanced,
      );
    }
  }

  /// Récupère la version actuellement affichée pour l'édition
  String getCurrentEditableText() {
    return state.displayText;
  }
}

/// Provider pour la transcription avec injection de dépendances
final transcriptionProvider = StateNotifierProvider<TranscriptionNotifier, TranscriptionState>((ref) {
  final transcriptionRepository = ref.watch(transcriptionRepositoryProvider);
  return TranscriptionNotifier(transcriptionRepository);
}); 