import 'package:flutter/material.dart';

/// Page des paramètres de l'application
class ParametresView extends StatelessWidget {
  const ParametresView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Page des paramètres (en construction)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 