import 'package:flutter/foundation.dart';

/// Un notificateur simple pour signaler que l'historique des notes a été modifié.
///
/// D'autres parties de l'application (comme la page d'historique) peuvent écouter
/// ce notificateur pour déclencher un rafraîchissement de leurs données
/// lorsqu'une nouvelle note est créée ou modifiée.
class HistoryNotifier extends ChangeNotifier {
  void notifyHistoryChanged() {
    notifyListeners();
  }
}

/// Instance globale et unique du notificateur d'historique.
final historyNotifier = HistoryNotifier(); 