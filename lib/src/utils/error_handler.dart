import 'package:flutter/material.dart';

/// Gestionnaire centralisé des messages d'erreur et de succès
/// 
/// Centralise l'affichage des SnackBar pour une interface utilisateur cohérente
/// et une maintenance plus facile des messages.
class ErrorHandler {
  
  /// Affiche un message d'erreur avec un style cohérent
  /// 
  /// [ctx] Le contexte Flutter pour afficher le message
  /// [msg] Le message d'erreur à afficher
  /// [duration] Durée d'affichage du message (par défaut 4 secondes)
  static void showError(
    BuildContext ctx, 
    String msg, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // Vérifier que le contexte est toujours monté avant d'afficher le message
    // Évite les crashes lors d'affichage de messages après navigation
    if (!ctx.mounted) return;
    
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un message de succès avec un style cohérent
  /// 
  /// [ctx] Le contexte Flutter pour afficher le message
  /// [msg] Le message de succès à afficher
  /// [duration] Durée d'affichage du message (par défaut 3 secondes)
  static void showSuccess(
    BuildContext ctx, 
    String msg, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // Vérifier que le contexte est toujours monté avant d'afficher le message
    // Évite les crashes lors d'affichage de messages après navigation
    if (!ctx.mounted) return;
    
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un message d'information avec un style cohérent
  /// 
  /// [ctx] Le contexte Flutter pour afficher le message
  /// [msg] Le message d'information à afficher
  /// [duration] Durée d'affichage du message (par défaut 3 secondes)
  static void showInfo(
    BuildContext ctx, 
    String msg, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // Vérifier que le contexte est toujours monté avant d'afficher le message
    // Évite les crashes lors d'affichage de messages après navigation
    if (!ctx.mounted) return;
    
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un message d'avertissement avec un style cohérent
  /// 
  /// [ctx] Le contexte Flutter pour afficher le message
  /// [msg] Le message d'avertissement à afficher
  /// [duration] Durée d'affichage du message (par défaut 3 secondes)
  static void showWarning(
    BuildContext ctx, 
    String msg, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // Vérifier que le contexte est toujours monté avant d'afficher le message
    // Évite les crashes lors d'affichage de messages après navigation
    if (!ctx.mounted) return;
    
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Fonctions globales pour un usage plus simple
/// 
/// Ces fonctions permettent d'utiliser le gestionnaire d'erreurs
/// sans avoir à préfixer par ErrorHandler à chaque fois.

/// Affiche un message d'erreur - raccourci global
void showError(BuildContext ctx, String msg, {Duration? duration}) {
  ErrorHandler.showError(ctx, msg, duration: duration ?? const Duration(seconds: 4));
}

/// Affiche un message de succès - raccourci global
void showSuccess(BuildContext ctx, String msg, {Duration? duration}) {
  ErrorHandler.showSuccess(ctx, msg, duration: duration ?? const Duration(seconds: 3));
}

/// Affiche un message d'information - raccourci global
void showInfo(BuildContext ctx, String msg, {Duration? duration}) {
  ErrorHandler.showInfo(ctx, msg, duration: duration ?? const Duration(seconds: 3));
}

/// Affiche un message d'avertissement - raccourci global
void showWarning(BuildContext ctx, String msg, {Duration? duration}) {
  ErrorHandler.showWarning(ctx, msg, duration: duration ?? const Duration(seconds: 3));
} 