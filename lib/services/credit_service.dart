import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/credit_repository.dart';

/// Un service pour gérer l'état des crédits de transcription de l'utilisateur.
///
/// Ce service utilise le pattern `ChangeNotifier` pour permettre aux widgets
/// de s'abonner aux changements de l'état des crédits et de se reconstruire
/// automatiquement lorsque les crédits sont mis à jour.
/// 
/// TODO: Écrire des tests unitaires pour CreditService
/// - Test d'ajout de crédits avec différentes valeurs
/// - Test de déduction de crédits sans aller en négatif
/// - Test de chargement/sauvegarde depuis le stockage local
/// - Test de hasEnoughCredits avec différents scénarios
/// - Test du stream de crédits pour réactivité
class CreditService extends ChangeNotifier implements CreditRepository {
  /// Les crédits totaux (en secondes) que l'utilisateur possède.
  /// La valeur initiale est de 10 minutes.
  int _totalCreditSeconds = 10 * 60;
  
  @override
  int get totalCreditSeconds => _totalCreditSeconds;

  /// Les crédits restants (en secondes) à l'utilisateur.
  /// Initialement, les crédits restants sont égaux aux crédits totaux.
  int _remainingCreditSeconds = 10 * 60;
  
  @override
  int get remainingCreditSeconds => _remainingCreditSeconds;

  /// Stream controller pour diffuser les changements de crédits
  late StreamController<int> _creditsStreamController;

  CreditService() {
    _creditsStreamController = StreamController<int>.broadcast();
  }

  @override
  bool hasEnoughCredits(int secondsNeeded) {
    return _remainingCreditSeconds >= secondsNeeded;
  }

  /// Ajoute des crédits (en secondes) au solde de l'utilisateur.
  ///
  /// Les crédits sont ajoutés à la fois au total et au solde restant.
  /// Après la mise à jour, les écouteurs sont notifiés.
  @override
  void addCredits(int secondsToAdd) {
    _totalCreditSeconds += secondsToAdd;
    _remainingCreditSeconds += secondsToAdd;
    _notifyChanges();
  }

  /// Déduit des crédits (en secondes) du solde de l'utilisateur.
  ///
  /// Utilisé après une transcription. Le solde ne peut pas tomber en dessous de zéro.
  @override
  void deductCredits(int secondsUsed) {
    _remainingCreditSeconds -= secondsUsed;
    if (_remainingCreditSeconds < 0) {
      _remainingCreditSeconds = 0;
    }
    _notifyChanges();
  }

  @override
  Future<void> loadCredits() async {
    // TODO: Implémenter le chargement depuis SharedPreferences
    // Pour l'instant, on garde les valeurs par défaut
  }

  @override
  Future<void> saveCredits() async {
    // TODO: Implémenter la sauvegarde vers SharedPreferences
  }

  @override
  void resetCredits() {
    _totalCreditSeconds = 10 * 60;
    _remainingCreditSeconds = 10 * 60;
    _notifyChanges();
  }

  @override
  Stream<int> get creditsStream => _creditsStreamController.stream;

  void _notifyChanges() {
    notifyListeners(); // Notifie les widgets qui écoutent ce service.
    _creditsStreamController.add(_remainingCreditSeconds);
  }

  @override
  void dispose() {
    _creditsStreamController.close();
    super.dispose();
  }
}

/// Instance globale et unique du service de crédits.
///
/// En rendant cette instance globale, n'importe quelle partie de l'application
/// peut y accéder pour lire ou modifier l'état des crédits.
final creditService = CreditService(); 