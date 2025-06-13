import 'package:flutter/material.dart';

/// Page de l'écran principal de transcription
class TranscriptionPage extends StatelessWidget {
  const TranscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Transcription',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 