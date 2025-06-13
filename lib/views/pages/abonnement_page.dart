import 'package:flutter/material.dart';

/// Page de gestion de l'abonnement
class AbonnementPage extends StatelessWidget {
  const AbonnementPage({Key? key}) : super(key: key);

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