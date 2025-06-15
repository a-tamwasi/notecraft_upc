import 'package:flutter/material.dart';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA PAGE D'HISTORIQUE
// --- //

/// Affiche la liste des transcriptions passées de l'utilisateur.
///
/// C'est un `StatelessWidget` car, dans sa forme actuelle, elle n'a pas besoin
/// de gérer un état interne. À l'avenir, si nous ajoutons des filtres ou des
/// tris interactifs, elle pourrait devenir un `StatefulWidget`.
class PageHistorique extends StatelessWidget {
  const PageHistorique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Historique',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 