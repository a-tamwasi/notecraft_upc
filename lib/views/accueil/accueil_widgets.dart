import 'dart:ui'; // Importe les classes pour les effets de rendu comme le flou
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notecraft_upc/views/abonnement/abonnement_page.dart';
import 'package:notecraft_upc/views/historique/historique_page.dart';
import 'package:notecraft_upc/views/transcription/transcription_page.dart';
import '../parametres/parametres_page.dart';
import '../../controllers/navigation_notifier.dart';

/// Le widget `VueAccueil` est le conteneur principal de l'application après la connexion.
/// Il gère la structure globale, y compris la barre d'onglets (BottomNavigationBar)
/// et l'affichage de la page actuellement sélectionnée.
class VueAccueil extends StatefulWidget {
  const VueAccueil({super.key});

  @override
  State<VueAccueil> createState() => _EtatVueAccueil();
}

class _EtatVueAccueil extends State<VueAccueil> {
  /// Conserve l'index de l'onglet actuellement sélectionné.
  /// `0` correspond à 'Transcription', `1` à 'Historique', etc.
  int _indexSelectionne = 0;

  /// Une liste contenant les différentes pages (widgets) accessibles via la barre de navigation.
  /// `late` est utilisé car nous l'initialisons dans `initState`.
  late final List<Widget> _pages;

  /// `initState` est appelée une seule fois à la création du widget.
  /// C'est ici que nous initialisons la liste des pages.
  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      // Page 0: La transcription (page principale)
      const PageTranscription(),
      // Page 1: L'historique
      const PageHistorique(),
      // Page 2: L'abonnement
      const PageAbonnement(),
    ];

    // Écoute les changements du notificateur de navigation
    navigationNotifier.addListener(_onNavigationNotification);
  }

  /// `dispose` est appelée lorsque le widget est retiré de l'arbre.
  /// Il est crucial de supprimer les écouteurs pour éviter les fuites de mémoire.
  @override
  void dispose() {
    navigationNotifier.removeListener(_onNavigationNotification);
    super.dispose();
  }

  /// Gère la notification de changement d'onglet.
  void _onNavigationNotification() {
    // On met à jour l'index seulement si la nouvelle valeur est différente de l'actuelle.
    if (_indexSelectionne != navigationNotifier.value) {
      _selectionnerOnglet(navigationNotifier.value);
    }
  }

  /// Cette fonction est appelée lorsqu'un onglet de la barre de navigation est touché.
  /// Elle met à jour l'état avec le nouvel index, ce qui déclenche un `build`
  /// pour afficher la page correspondante.
  void _selectionnerOnglet(int index) {
    setState(() {
      _indexSelectionne = index;
    });
    // On met aussi à jour le notificateur pour que l'état soit cohérent
    // si d'autres parties de l'app l'écoutent.
    if (navigationNotifier.value != index) {
      navigationNotifier.value = index;
    }
  }

  /// La méthode `build` construit l'interface visuelle de la vue.
  @override
  Widget build(BuildContext context) {
    // `Scaffold` est un widget de mise en page de base de Material Design.
    // Il fournit le cadre pour l'AppBar, le corps (body), la barre de navigation, etc.
    return Scaffold(
      // `extendBody: true` permet au contenu du `body` de s'étendre sous la barre de navigation,
      // ce qui est nécessaire pour l'effet de transparence (glassmorphism).
      extendBody: true,
      
      // La barre d'application en haut de l'écran.
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Garde la couleur blanche même pendant le scroll
        scrolledUnderElevation: 0, // Désactive l'effet d'élévation lors du scroll
        title: Image.asset('assets/images/logo.png', height: 150),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VueParametres()),
              );
            },
            tooltip: 'Ouvrir les paramètres',
          ),
        ],
      ),
      
      // Le corps principal de l'écran.
      // Nous utilisons un `Stack` pour superposer la page de contenu et la barre de navigation.
      body: Stack(
        children: [
          // `IndexedStack` est un widget qui n'affiche qu'un seul de ses enfants à la fois,
          // déterminé par son `index`. C'est très efficace pour la navigation par onglets
          // car il conserve l'état de chaque page même lorsqu'elle n'est pas visible.
          IndexedStack(
            index: _indexSelectionne,
            children: _pages,
          ),
          
          // La barre de navigation est positionnée en bas de l'écran.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _construireBarreNavigationEffetVerre(),
          ),
        ],
      ),
      
      // On met `bottomNavigationBar` à `null` car nous avons déjà positionné
      // notre barre personnalisée à l'intérieur du `Stack` du `body`.
      bottomNavigationBar: null,
    );
  }

  /// Construit la barre de navigation avec un effet de "verre dépoli" (glassmorphism).
  Widget _construireBarreNavigationEffetVerre() {
    // `ClipRRect` est utilisé pour s'assurer que l'effet de flou ne "déborde" pas.
    return ClipRRect(
      // `BackdropFilter` applique un filtre (ici, un flou) à la zone située derrière ce widget.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          // La décoration donne à la barre sa couleur semi-transparente et sa bordure supérieure.
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
          ),
          // `SafeArea` garantit que la barre de navigation ne sera pas obstruée par des
          // éléments de l'interface du système (comme la barre d'accueil sur iOS).
          child: SafeArea(
            top: false, // On n'applique la zone de sécurité qu'en bas.
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Iconsax.microphone_2), label: 'Transcription'),
                BottomNavigationBarItem(icon: Icon(Iconsax.document_text_1), label: 'Historique'),
                BottomNavigationBarItem(icon: Icon(Iconsax.crown_1), label: 'Abonnement'),
              ],
              currentIndex: _indexSelectionne,
              onTap: _selectionnerOnglet,
              
              // --- Style pour l'effet de verre ---
              backgroundColor: Colors.transparent, // Le fond doit être transparent pour que le flou soit visible.
              elevation: 0, // Aucune ombre pour un look épuré.
              type: BottomNavigationBarType.fixed, // Assure que tous les libellés sont visibles.
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