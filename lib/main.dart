import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/constants/couleurs_application.dart';
import 'views/vue_accueil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  await initializeDateFormatting('fr_FR', null);
  
  runApp(const NoteCraftApp());
}

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
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const VueAccueil(),
    );
  }
}
