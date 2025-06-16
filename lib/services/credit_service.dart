import 'package:flutter/foundation.dart';

/// Un service pour gérer l'état des crédits de transcription de l'utilisateur.
///
/// Ce service utilise le pattern `ChangeNotifier` pour permettre aux widgets
/// de s'abonner aux changements de l'état des crédits et de se reconstruire
/// automatiquement lorsque les crédits sont mis à jour.
class CreditService extends ChangeNotifier {
  /// Les crédits totaux (en secondes) que l'utilisateur possède.
  /// La valeur initiale est de 10 minutes.
  int _totalCreditSeconds = 10 * 60;
  int get totalCreditSeconds => _totalCreditSeconds;

  /// Les crédits restants (en secondes) à l'utilisateur.
  /// Initialement, les crédits restants sont égaux aux crédits totaux.
  int _remainingCreditSeconds = 10 * 60;
  int get remainingCreditSeconds => _remainingCreditSeconds;

  /// Ajoute des crédits (en secondes) au solde de l'utilisateur.
  ///
  /// Les crédits sont ajoutés à la fois au total et au solde restant.
  /// Après la mise à jour, les écouteurs sont notifiés.
  void addCredits(int seconds) {
    _totalCreditSeconds += seconds;
    _remainingCreditSeconds += seconds;
    notifyListeners(); // Notifie les widgets qui écoutent ce service.
  }

  /// Déduit des crédits (en secondes) du solde de l'utilisateur.
  ///
  /// Utilisé après une transcription. Le solde ne peut pas tomber en dessous de zéro.
  void deductCredits(int seconds) {
    _remainingCreditSeconds -= seconds;
    if (_remainingCreditSeconds < 0) {
      _remainingCreditSeconds = 0;
    }
    notifyListeners(); // Notifie les widgets qui écoutent ce service.
  }
}

/// Instance globale et unique du service de crédits.
///
/// En rendant cette instance globale, n'importe quelle partie de l'application
/// peut y accéder pour lire ou modifier l'état des crédits.
final creditService = CreditService(); 