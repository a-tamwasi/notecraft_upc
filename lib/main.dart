import 'package:flutter/material.dart';
import 'src/constants/couleurs_application.dart';

void main() => runApp(const NoteCraftApp());

/// Application principale NoteCraft
/// Convertit les audios en texte via l'API OpenAI
class NoteCraftApp extends StatelessWidget {
  const NoteCraftApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteCraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: CouleursApplication.primaire,
        useMaterial3: true,
      ),
      home: const Accueil(),
    );
  }
}

/// Page d'accueil temporaire
/// Sera remplacée par la vraie vue d'accueil
class Accueil extends StatelessWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteCraft'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenue dans NoteCraft',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Convertissez vos audios en texte',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
