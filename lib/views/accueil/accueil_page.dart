import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notecraft_upc/models/astuce_model.dart';
import 'package:notecraft_upc/models/note_model.dart';
import 'package:notecraft_upc/src/utils/formateurs.dart';

/// Un `StatefulWidget` est un widget qui peut maintenir un état.
/// C'est-à-dire qu'il peut changer d'apparence en réponse à des événements (ex: interaction de l'utilisateur, arrivée de données).
/// Il est composé de deux classes : le widget lui-même (ici, `PageAccueil`) et sa classe d'état (`_EtatPageAccueil`).
class PageAccueil extends StatefulWidget {
  // --- Propriétés Finales ---
  // Ces callbacks sont des fonctions passées depuis le widget parent (probablement la page principale avec la barre de navigation).
  // Elles permettent à cette page de communiquer vers le haut pour demander un changement de page.
  
  /// Callback pour demander la navigation vers la page de transcription.
  final VoidCallback onNaviguerVersTranscription;
  /// Callback pour demander la navigation vers la page d'abonnement.
  final VoidCallback onNaviguerVersAbonnement;

  /// Le constructeur du widget.
  /// `super.key` est passé au constructeur parent pour une gestion efficace des widgets par Flutter.
  const PageAccueil({
    super.key,
    required this.onNaviguerVersTranscription,
    required this.onNaviguerVersAbonnement,
  });

  /// C'est la méthode que Flutter appelle pour créer l'objet "état" associé à ce widget.
  /// C'est ici que toute la logique et l'interface de la page seront gérées.
  @override
  State<PageAccueil> createState() => _EtatPageAccueil();
}

/// La classe `State` contient la logique et l'interface utilisateur de notre `StatefulWidget`.
/// Le préfixe `_` rend la classe privée, ce qui signifie qu'elle ne peut être utilisée que dans ce fichier.
class _EtatPageAccueil extends State<PageAccueil> {
  // --- Variables d'État ---
  // Un `Future` représente une valeur qui sera disponible dans le futur.
  // On les utilise ici pour gérer les données qui doivent être chargées de manière asynchrone (ex: depuis une base de données).
  // Le `late` mot-clé promet au compilateur que nous initialiserons ces variables avant de les utiliser, typiquement dans `initState`.

  late Future<String?> _futurePrenomUtilisateur;
  late Future<Note?> _futureDerniereNote;
  late Future<Map<String, int>> _futureStatistiques;
  late Future<List<Astuce>> _futureAstuces;

  /// La méthode `initState` est appelée une seule fois lorsque le widget est inséré dans l'arbre des widgets.
  /// C'est l'endroit idéal pour initialiser les données, les contrôleurs, ou lancer des chargements de données.
  @override
  void initState() {
    super.initState();
    // On lance ici le chargement de toutes les données nécessaires pour la page.
    _futurePrenomUtilisateur = _chargerPrenomUtilisateur();
    _futureDerniereNote = _chargerDerniereNote();
    _futureStatistiques = _chargerStatistiques();
    _futureAstuces = _chargerAstuces();
  }

  // --- Méthodes de Chargement des Données ---
  // Ces méthodes simulent la récupération de données. Dans une vraie application,
  // elles feraient appel à un `Repository` ou un `Service` pour parler à une base de données ou une API.

  /// Simule la récupération du prénom de l'utilisateur.
  Future<String?> _chargerPrenomUtilisateur() async {
    return null; // Pour l'instant, on suppose qu'aucun utilisateur n'est connecté.
  }

  /// Simule la récupération de la dernière note ou transcription.
  Future<Note?> _chargerDerniereNote() async {
    return null; // Pour l'instant, aucune note n'est disponible.
  }

  /// Simule la récupération des statistiques de l'utilisateur.
  Future<Map<String, int>> _chargerStatistiques() async {
    return {'transcriptions': 0, 'audios': 0}; // Valeurs par défaut.
  }

  /// Fournit une liste d'astuces statiques pour l'affichage.
  Future<List<Astuce>> _chargerAstuces() async {
    return [
      Astuce(
        titre: 'Clarté et Calme',
        contenu: 'Pour une transcription précise, enregistrez dans un endroit calme et articulez distinctement.',
        imageUrl: 'assets/images/conseil1.png',
      ),
      Astuce(
        titre: 'Utilisez un bon micro',
        contenu: 'Un bon micro externe améliore la qualité audio et réduit les erreurs de transcription.',
        imageUrl: 'assets/images/conseil2.png',
      ),
      Astuce(
        titre: 'Marquez des pauses',
        contenu: 'Faire une pause entre les phrases aide l\'IA à mieux structurer le texte et la ponctuation.',
        imageUrl: 'assets/images/conseil3.png',
      ),
      Astuce(
        titre: 'Parlez posément',
        contenu: "Laissez à l'algorithme le temps d'assimiler chaque mot pour une transcription fidèle.",
        imageUrl: 'assets/images/conseil4.png',
      ),
      Astuce(
        titre: 'Choisissez la bonne langue',
        contenu: 'Sélectionner la langue correcte dans les paramètres améliore grandement la reconnaissance vocale.',
        imageUrl: 'assets/images/conseil5.png',
      ),
    ];
  }

  /// La méthode `build` est la plus importante. Elle est appelée par Flutter chaque fois que
  /// l'interface doit être (re)dessinée. Elle retourne l'arbre des widgets qui compose la page.
  @override
  Widget build(BuildContext context) {
    // `Container` sert de fond de page.
    return Container(
      color: Colors.white,
      // `ListView` est un widget qui permet de faire défiler une liste d'enfants.
      // C'est idéal pour une page d'accueil qui peut contenir plus de contenu que ce que l'écran peut afficher.
      child: ListView(
        // Le `padding` ajoute de l'espace autour du contenu pour éviter qu'il ne colle aux bords.
        padding: const EdgeInsets.only(bottom: 90), // Espace en bas pour la barre de navigation.
        // `children` est la liste des widgets qui seront affichés dans la ListView.
        children: [
          // Chaque section de la page est séparée pour une meilleure lisibilité du code.

          // --- SECTION 1 : Message de bienvenue ---
          _construireSectionBienvenue(),

          // --- SECTION 2 : Carte de la dernière note ---
          _construireTitreSection("Récente"),
          _construireCarteDerniereNote(),
          const SizedBox(height: 24), // Espaceur vertical

          // --- SECTION 3 : Bouton d'action principal (Call To Action) ---
          _construireBoutonNouvelleTranscription(),
          
          // --- SECTION 4 : Cartes de statistiques ---
          _construireTitreSection("Statistiques Express"),
          _construireSectionStatistiques(),
          const SizedBox(height: 24),

          // --- SECTION 5 : Carrousel d'astuces ---
          _construireTitreSection("Astuces"),
          _construireCarrouselAstuces(),
          const SizedBox(height: 24),

          // --- SECTION 6 : Carte d'abonnement ---
          _construireCarteAbonnement(),
        ],
      ),
    );
  }
  
  // --- //
  // 3. MÉTHODES DE CONSTRUCTION DES WIDGETS (BUILDERS)
  // --- //
  // Découper l'interface en petites méthodes de construction rend le code `build` principal
  // beaucoup plus lisible et facile à maintenir. Chaque méthode a une seule responsabilité.

  /// Construit la section de bienvenue avec le message personnalisé.
  Widget _construireSectionBienvenue() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      // `FutureBuilder` est un widget essentiel pour construire une interface basée sur un `Future`.
      // Il gère les différents états (en attente, erreur, données reçues) pour nous.
      child: FutureBuilder<String?>(
        future: _futurePrenomUtilisateur, // Le Future que ce widget écoute.
        builder: (context, snapshot) {
          // Le `builder` est la fonction qui construit l'interface en fonction de l'état du Future.
          // `snapshot` contient l'état actuel et les données (si disponibles).
          
          String message = "Bienvenue !"; // Message par défaut.
          
          // On vérifie si le Future est terminé (`done`) et s'il contient des données.
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            message = "Bienvenue, ${snapshot.data} !"; // On personnalise le message.
          }

          return Row(
            children: [
              const Text('👋', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              // `AnimatedSwitcher` permet une transition en fondu lorsque le texte change.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  message,
                  key: ValueKey<String>(message), // La clé est cruciale pour que l'animation fonctionne.
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Construit un titre de section standard.
  Widget _construireTitreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        titre,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
  
  /// Construit la carte affichant la dernière note, ou un message si elle n'existe pas.
  Widget _construireCarteDerniereNote() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: FutureBuilder<Note?>(
        future: _futureDerniereNote,
        builder: (context, snapshot) {
          // Affiche un indicateur de chargement pendant que les données sont récupérées.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _construireIndicateurChargementCarte();
          }
          // Si on a reçu une note, on affiche la carte correspondante.
          if (snapshot.hasData && snapshot.data != null) {
            return _construireCarteNote(snapshot.data!);
          }
          // Sinon, on affiche un message indiquant qu'il n'y a pas de notes.
          return _construireMessageVide("Aucune transcription pour l'instant.");
        },
      ),
    );
  }

  /// Construit le bouton principal pour lancer une nouvelle transcription.
  Widget _construireBoutonNouvelleTranscription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.lightBlue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        ),
        child: ElevatedButton.icon(
          // On utilise le callback passé en paramètre du widget `PageAccueil`.
          onPressed: widget.onNaviguerVersTranscription,
          icon: const Icon(Iconsax.magicpen, size: 20, color: Colors.white),
          label: const Text('Nouvelle Transcription Rapide'),
          // Style pour un bouton moderne et personnalisé.
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Le dégradé du `DecoratedBox` sert de fond.
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Construit la section des statistiques.
  Widget _construireSectionStatistiques() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: FutureBuilder<Map<String, int>>(
        future: _futureStatistiques,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _construireIndicateurChargementStats();
          }

          final stats = snapshot.data ?? {'transcriptions': 0, 'audios': 0};
          return Row(
            children: [
              Expanded(child: _construireCarteStatistique('Transcriptions', stats['transcriptions']!, Iconsax.document_text_1)),
              const SizedBox(width: 16),
              Expanded(child: _construireCarteStatistique('Audios analysés', stats['audios']!, Iconsax.microphone_2)),
            ],
          );
        },
      ),
    );
  }

  /// Construit le carrousel horizontal des cartes d'astuces.
  Widget _construireCarrouselAstuces() {
    return SizedBox(
      height: 160, // Hauteur fixe pour le carrousel
      child: FutureBuilder<List<Astuce>>(
        future: _futureAstuces,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink(); // Ne rien afficher si pas de données.
          }
          final astuces = snapshot.data!;
          // `ListView.builder` est très performant pour les longues listes,
          // car il ne construit les éléments que lorsqu'ils deviennent visibles.
          return ListView.builder(
            scrollDirection: Axis.horizontal, // Fait défiler la liste horizontalement.
            itemCount: astuces.length,
            itemBuilder: (context, index) {
              final estDernierElement = index == astuces.length - 1;
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 24 : 16, // Padding à gauche du premier élément.
                  right: estDernierElement ? 24 : 0, // Padding à droite du dernier.
                ),
                child: _construireCarteAstuce(astuces[index]),
              );
            },
          );
        },
      ),
    );
  }
  
  /// Construit la carte d'appel à l'action pour l'abonnement avec une meilleure visibilité sur mobile.
  Widget _construireCarteAbonnement() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      // Ajout d'une ombre douce autour de toute la carte pour améliorer sa visibilité.
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // Ombre subtile mais visible
              blurRadius: 8, // Diffusion de l'ombre
              offset: const Offset(0, 4), // Décalage vertical pour un effet naturel
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onNaviguerVersAbonnement, // Utilise le callback de navigation.
          borderRadius: BorderRadius.circular(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/abonnement2.png', fit: BoxFit.cover),
                  // Dégradé renforcé pour une meilleure lisibilité du texte sur l'image.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.7)], // Dégradé plus prononcé
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0], // Transition plus rapide vers le noir
                      ),
                    ),
                  ),
                  // Texte positionné plus bas avec une ombre renforcée pour une meilleure visibilité.
                  Positioned(
                    left: 20,
                    bottom: 12, // Baissé de 20 à 12 pour descendre le texte
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passez à NoteCraft+',
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white, 
                            shadows: [
                              // Ombre plus prononcée pour une meilleure lisibilité
                              Shadow(
                                blurRadius: 4, 
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(1, 1), // Léger décalage pour plus de profondeur
                              ),
                              // Deuxième ombre pour renforcer l'effet
                              Shadow(
                                blurRadius: 8, 
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ]
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Débloquez les transcriptions illimitées et les fonctionnalités avancées.',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.white, 
                            shadows: [
                              // Même traitement d'ombre pour le sous-titre
                              Shadow(
                                blurRadius: 3, 
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(1, 1),
                              ),
                              Shadow(
                                blurRadius: 6, 
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Composants (Petits éléments réutilisables) ---
  
  /// Construit la carte pour une note spécifique.
  Widget _construireCarteNote(Note note) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: Text(note.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(Formateurs.formaterDateLongue(note.dateCreation), style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ),
        trailing: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.blueAccent.shade100],
          ).createShader(bounds),
          child: const Icon(Icons.graphic_eq, size: 45, color: Colors.white),
        ),
        onTap: () { /* TODO: Naviguer vers les détails de la note */ },
      ),
    );
  }

  /// Construit un message générique à afficher lorsqu'une section est vide.
  Widget _construireMessageVide(String message) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  /// Construit un indicateur de chargement pour une carte.
  Widget _construireIndicateurChargementCarte() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 34.0, horizontal: 20.0),
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
    );
  }

  /// Construit un indicateur de chargement pour la section des statistiques.
  Widget _construireIndicateurChargementStats() {
    return Row(
      children: [
        Expanded(child: Container(height: 95, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)))),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 95, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)))),
      ],
    );
  }

  /// Construit une carte pour une statistique individuelle.
  Widget _construireCarteStatistique(String label, int valeur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      height: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(valeur.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(icone, size: 22, color: Theme.of(context).primaryColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  /// Construit une carte pour une astuce individuelle.
  Widget _construireCarteAstuce(Astuce astuce) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InkWell(
        onTap: () => _afficherDialogueDetailsAstuce(context, astuce),
        borderRadius: BorderRadius.circular(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(astuce.imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(astuce.titre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 2, color: Colors.black54)])),
                    const SizedBox(height: 4),
                    Text(astuce.contenu, style: const TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(blurRadius: 2, color: Colors.black87)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue modale avec les détails de l'astuce.
  void _afficherDialogueDetailsAstuce(BuildContext context, Astuce astuce) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              height: 450,
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(astuce.imageUrl), fit: BoxFit.cover, alignment: Alignment.topCenter)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.5, 1.0]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(astuce.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black87)])),
                            const SizedBox(height: 12),
                            Text(astuce.contenu, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4, shadows: [Shadow(blurRadius: 2, color: Colors.black87)])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Compris', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 