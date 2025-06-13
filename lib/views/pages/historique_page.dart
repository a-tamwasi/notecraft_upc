import 'package:flutter/material.dart';

/// Page affichant l'historique des transcriptions
class HistoriquePage extends StatelessWidget {
  const HistoriquePage({Key? key}) : super(key: key);

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