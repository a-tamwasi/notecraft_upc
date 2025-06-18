import 'package:flutter/foundation.dart';

/// Un notificateur global pour contrôler l'index de la barre de navigation.
///
/// D'autres parties de l'application peuvent écouter ce notificateur pour
/// être informées des changements d'onglet ou mettre à jour sa valeur pour
/// déclencher une navigation.
///
/// La valeur initiale est 0, ce qui correspond à la page d'accueil.
final navigationNotifier = ValueNotifier<int>(0); 