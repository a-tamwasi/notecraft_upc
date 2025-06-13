import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notecraft_upc/models/astuce_model.dart';
import 'package:notecraft_upc/models/transcription_model.dart';
import 'package:notecraft_upc/src/utils/formateurs.dart';

/// Contenu de la page d'accueil principale
class AccueilPage extends StatefulWidget {
  /// Callback pour naviguer vers l'onglet de transcription.
  final VoidCallback onNavigateToTranscription;
  /// Callback pour naviguer vers l'onglet d'abonnement.
  final VoidCallback onNavigateToAbonnement;

  const AccueilPage({
    Key? key,
    required this.onNavigateToTranscription,
    required this.onNavigateToAbonnement,
  }) : super(key: key);

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late Future<String?> _prenomUtilisateurFuture;
  late Future<TranscriptionModel?> _derniereTranscriptionFuture;
  late Future<Map<String, int>> _statistiquesFuture;
  late Future<List<AstuceModel>> _astucesFuture;

  @override
  void initState() {
    super.initState();
    _prenomUtilisateurFuture = _recupererPrenomUtilisateur();
    _derniereTranscriptionFuture = _recupererDerniereTranscription();
    _statistiquesFuture = _recupererStatistiques();
    _astucesFuture = _recupererAstuces();
  }

  /// Récupère le prénom de l'utilisateur.
  /// À l'avenir, cette méthode appellera votre service de gestion de profil.
  /// Pour l'instant, elle retourne null car aucun utilisateur n'est connecté.
  Future<String?> _recupererPrenomUtilisateur() async {
    // Pas de simulation, on retourne l'état réel (pas d'utilisateur)
    return null;
  }

  /// Récupère la dernière transcription.
  /// Pour l'instant, elle retourne null car la fonctionnalité n'est pas implémentée.
  Future<TranscriptionModel?> _recupererDerniereTranscription() async {
    // Pas de simulation, on retourne l'état réel (pas de transcription)
    return null;
  }

  /// Récupère les statistiques de l'utilisateur.
  /// Pour l'instant, elle retourne 0 car aucune action n'a été faite.
  Future<Map<String, int>> _recupererStatistiques() async {
    // Pas de simulation, on retourne l'état réel (pas de stats)
    return {'transcriptions': 0, 'audios': 0};
  }

  /// Récupère une liste d'astuces pour l'utilisateur.
  Future<List<AstuceModel>> _recupererAstuces() async {
    // Les astuces sont maintenant personnalisées selon vos instructions.
    return [
      AstuceModel(
        titre: 'Clarté et Calme',
        contenu: 'Pour une transcription précise, enregistrez dans un endroit calme et articulez distinctement.',
        cheminImage: 'assets/images/conseil1.png',
      ),
      AstuceModel(
        titre: 'Utilisez un bon micro',
        contenu: 'Un bon micro externe améliore la qualité audio et réduit les erreurs de transcription.',
        cheminImage: 'assets/images/conseil2.png',
      ),
      AstuceModel(
        titre: 'Marquez des pauses',
        contenu: 'Faire une pause entre les phrases aide l\'IA à mieux structurer le texte et la ponctuation.',
        cheminImage: 'assets/images/conseil3.png',
      ),
      AstuceModel(
        titre: 'Parlez posément',
        contenu: "Laissez à l'algorithme le temps d'assimiler chaque mot pour une transcription fidèle.",
        cheminImage: 'assets/images/conseil4.png',
      ),
      AstuceModel(
        titre: 'Choisissez la bonne langue',
        contenu: 'Sélectionner la langue correcte dans les paramètres améliore grandement la reconnaissance vocale.',
        cheminImage: 'assets/images/conseil5.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 90), // Espace pour la barre de nav
        children: [
          // --- Section de bienvenue ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: FutureBuilder<String?>(
              future: _prenomUtilisateurFuture,
              builder: (context, snapshot) {
                // On affiche "Bienvenue !" par défaut
                String message = "Bienvenue !";

                // Si les données sont chargées et qu'un prénom existe, on personnalise
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  message = "Bienvenue, ${snapshot.data} !";
                }

                return Row(
                  children: [
                    const Text('👋', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    // AnimatedSwitcher pour une transition douce du texte
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        message,
                        key: ValueKey<String>(message), // Important pour l'animation
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- Section dernière transcription ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Récente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FutureBuilder<TranscriptionModel?>(
              future: _derniereTranscriptionFuture,
              builder: (context, snapshot) {
                // On affiche un placeholder uniquement si on attend vraiment des données
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildPlaceholder();
                }
                // Si on a des données, on affiche la carte
                if (snapshot.hasData && snapshot.data != null) {
                  return _buildDerniereTranscriptionCard(snapshot.data!);
                }
                // Sinon (pas de données, erreur, etc.), on affiche l'état vide
                return _buildDerniereTranscriptionVide();
              },
            ),
          ),

          // --- CTA Nouvelle Transcription ---
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Colors.lightBlue.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              child: ElevatedButton.icon(
                onPressed: widget.onNavigateToTranscription,
                icon: const Icon(Iconsax.magicpen, size: 20, color: Colors.white),
                label: const Text('Nouvelle Transcription Rapide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // --- Section Statistiques Express ---
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Statistiques Express",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FutureBuilder<Map<String, int>>(
              future: _statistiquesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildStatsPlaceholder();
                }

                final stats = snapshot.data ?? {'transcriptions': 0, 'audios': 0};
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Transcriptions',
                        stats['transcriptions']!,
                        Iconsax.document_text_1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Audios analysés',
                        stats['audios']!,
                        Iconsax.microphone_2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- Section Astuces ---
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Astuces",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: FutureBuilder<List<AstuceModel>>(
              future: _astucesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // On peut afficher un placeholder ou simplement ne rien afficher
                  return const SizedBox.shrink();
                }
                final astuces = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: astuces.length,
                  itemBuilder: (context, index) {
                    // Ajoute un padding pour tous les éléments sauf le dernier
                    final isLastItem = index == astuces.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 24 : 16,
                        right: isLastItem ? 24 : 0,
                      ),
                      child: _buildAstuceCard(astuces[index]),
                    );
                  },
                );
              },
            ),
          ),

          // --- CTA Abonnement ---
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildAbonnementCard(context),
          ),
        ],
      ),
    );
  }

  /// Widget pour la carte de la dernière transcription.
  Widget _buildDerniereTranscriptionCard(TranscriptionModel transcription) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: Text(
          transcription.nomFichierSource ?? 'Transcription',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            Formateurs.formaterDateLongue(transcription.dateTranscription),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        trailing: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Colors.blueAccent.shade100,
            ],
          ).createShader(bounds),
          child: const Icon(
            Icons.graphic_eq,
            size: 45,
            color: Colors.white,
          ),
        ),
        onTap: () {
          // TODO: Naviguer vers l'écran de détails de cette transcription
        },
      ),
    );
  }

  /// Widget affiché quand aucune transcription n'est disponible.
  Widget _buildDerniereTranscriptionVide() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Text(
          "Aucune transcription effectuée pour l'instant.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Widget affiché pendant le chargement.
  Widget _buildPlaceholder() {
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

  /// Widget affiché pendant le chargement des statistiques.
  Widget _buildStatsPlaceholder() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 95,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 95,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget pour une carte de statistique individuelle.
  Widget _buildStatCard(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(icon, size: 22, color: Theme.of(context).primaryColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Widget pour une carte d'astuce.
  Widget _buildAstuceCard(AstuceModel astuce) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InkWell(
        onTap: () => _showAstuceDetailsDialog(context, astuce),
        borderRadius: BorderRadius.circular(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond
              Image.asset(
                astuce.cheminImage,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              // Dégradé pour la lisibilité du texte
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
              // Contenu texte
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astuce.titre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      astuce.contenu,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue avec les détails de l'astuce.
  void _showAstuceDetailsDialog(BuildContext context, AstuceModel astuce) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              height: 450, // Hauteur de la carte
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(astuce.cheminImage),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              astuce.titre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              astuce.contenu,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.4,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Compris',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
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

  /// Widget pour la carte d'appel à l'action pour l'abonnement.
  Widget _buildAbonnementCard(BuildContext context) {
    return InkWell(
      onTap: widget.onNavigateToAbonnement,
      borderRadius: BorderRadius.circular(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/abonnement2.png',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
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
                        shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.7))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Débloquez les transcriptions illimitées et les fonctionnalités avancées.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.7))],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 