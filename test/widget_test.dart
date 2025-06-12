// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notecraft_upc/main.dart';

void main() {
  testWidgets('Affiche l\'écran d\'accueil', (WidgetTester tester) async {
    // Construit l'application et déclenche un rendu.
    await tester.pumpWidget(const NoteCraftApp());

    // Vérifie que le message de bienvenue et le sous-titre sont affichés.
    expect(find.text('Bienvenue dans NoteCraft'), findsOneWidget);
    expect(find.text('Convertissez vos audios en texte'), findsOneWidget);

    // Vérifie que l'icône du microphone est présente.
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
