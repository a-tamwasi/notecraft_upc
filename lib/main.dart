import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/constants/couleurs_application.dart';
import 'views/accueil/accueil_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  // Diagnostic : vérifier le chargement des clés API
  print('🔍 Diagnostic API Keys:');
  print('   Deepgram API Key: ${dotenv.env['DEEPGRAM_API_KEY'] != null ? "✅ Chargée" : "❌ Manquante"}');
  print('   OpenAI API Key: ${dotenv.env['OPENAI_API_KEY'] != null ? "✅ Chargée" : "❌ Manquante"}');
  
  await initializeDateFormatting('fr_FR', null);
  
  runApp(
    const ProviderScope(
      child: NoteCraftApp(),
    ),
  );
}

/// Application principale NoteCraft
/// Convertit les audios en texte via l'API OpenAI
class NoteCraftApp extends StatelessWidget {
  const NoteCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteCraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: CouleursApplication.primaire,
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const VueAccueil(),
    );
  }
}
