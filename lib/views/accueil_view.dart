import 'dart:ui'; // Importe les classes pour les effets de rendu comme le flou
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notecraft_upc/views/pages/abonnement_page.dart';
import 'package:notecraft_upc/views/pages/accueil_page.dart';
import 'package:notecraft_upc/views/pages/historique_page.dart';
import 'package:notecraft_upc/views/pages/transcription_page.dart';
import 'parametres_view.dart';

/// Vue principale contenant la navigation par onglets
class AccueilView extends StatefulWidget {
  const AccueilView({Key? key}) : super(key: key);

  @override
  State<AccueilView> createState() => _AccueilViewState();
}

class _AccueilViewState extends State<AccueilView> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      AccueilPage(
        onNavigateToTranscription: () => _onItemTapped(1),
        onNavigateToAbonnement: () => _onItemTapped(3),
      ),
      const TranscriptionPage(),
      const HistoriquePage(),
      const AbonnementPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Le Scaffold est la base de notre page
    return Scaffold(
      // Permet au corps de la page de s'étendre derrière la barre de navigation
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/logo.png',
          height: 150, // Vous pouvez ajuster cette hauteur
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParametresView()),
              );
            },
            tooltip: 'Ouvrir les paramètres',
          ),
        ],
      ),
      // Le body est maintenant un Stack pour superposer le contenu et la barre de nav
      body: Stack(
        children: [
          // Le contenu de la page active
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // La barre de navigation est positionnée en bas par-dessus le contenu
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildGlassmorphicNavBar(),
          ),
        ],
      ),
      // La barre de navigation est maintenant construite dans le body
      // pour permettre la superposition, donc on la met à null ici.
      bottomNavigationBar: null,
    );
  }

  /// Construit la barre de navigation avec l'effet de verre
  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false, // On ne veut la zone de sécurité qu'en bas
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home_2),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.microphone_2),
                  label: 'Transcription',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.document_text_1),
                  label: 'Historique',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.crown_1),
                  label: 'Abonnement',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              // Style pour l'effet de verre
              backgroundColor: Colors.transparent, // Fond transparent
              elevation: 0, // Pas d'ombre
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.black54,
              showUnselectedLabels: true,
            ),
          ),
        ),
      ),
    );
  }
} 