/// Interface abstraite pour la gestion des crédits de transcription
/// Permet de mocker facilement pour les tests unitaires
abstract class CreditRepository {
  /// Nombre de secondes de crédit restantes
  int get remainingCreditSeconds;
  
  /// Nombre total de secondes de crédit
  int get totalCreditSeconds;
  
  /// Indique si l'utilisateur a suffisamment de crédits
  /// [secondsNeeded] : nombre de secondes nécessaires
  /// Retourne true si les crédits sont suffisants
  bool hasEnoughCredits(int secondsNeeded);
  
  /// Déduit des crédits après une transcription
  /// [secondsUsed] : nombre de secondes à déduire
  void deductCredits(int secondsUsed);
  
  /// Ajoute des crédits (après un achat par exemple)
  /// [secondsToAdd] : nombre de secondes à ajouter
  void addCredits(int secondsToAdd);
  
  /// Recharge les crédits depuis le stockage local
  Future<void> loadCredits();
  
  /// Sauvegarde les crédits dans le stockage local
  Future<void> saveCredits();
  
  /// Remet à zéro tous les crédits (pour les tests ou reset)
  void resetCredits();
  
  /// Stream des changements de crédits pour réactivité
  Stream<int> get creditsStream;
} 