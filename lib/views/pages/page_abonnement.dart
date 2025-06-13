import 'package:flutter/material.dart';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA PAGE D'ABONNEMENT
// --- //

/// Présente les offres d'abonnement et permet à l'utilisateur de souscrire.
///
/// Cette page est actuellement un `StatelessWidget`. Elle pourrait devenir
/// un `StatefulWidget` si elle devait, par exemple, charger les détails des offres
/// depuis un serveur ou gérer la sélection interactive des plans.
class PageAbonnement extends StatelessWidget {
  const PageAbonnement({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Abonnement',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 