import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../widgets/parametre_option_widget.dart';
import '../../widgets/avatar_profil_widget.dart';
import 'informations_personnelles_page.dart';
import 'moyens_paiement_page.dart';
import 'confidentialite_securite_page.dart';
import 'support_page.dart';

class VueParametres extends ConsumerStatefulWidget {
  const VueParametres({super.key});

  @override
  ConsumerState<VueParametres> createState() => _VueParametresState();
}

class _VueParametresState extends ConsumerState<VueParametres> {
  // État de connexion de l'utilisateur
  // TODO: Remplacer par la vraie logique de vérification de connexion
  bool _estConnecte = true;

  @override
  void initState() {
    super.initState();
    // Initialiser l'image de profil au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialiserImageProfil();
    });
  }

  /// Initialise l'image de profil si elle existe
  Future<void> _initialiserImageProfil() async {
    // TODO: Charger l'image de profil depuis la base de données ou les préférences
    // Pour l'instant, on peut laisser vide ou utiliser une image par défaut
    // final imageProvider = ref.read(imageProfilProvider.notifier);
    // await imageProvider.chargerImageProfil(cheminImageExistante);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: CouleursApplication.textePrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF0F4FF), // Même couleur que le début du dégradé
        elevation: 0, // Pas d'ombre pour fusionner avec le dégradé
        iconTheme: const IconThemeData(color: CouleursApplication.textePrincipal),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSectionEnTete(),
          Expanded(
            child: _buildListeOptionsParametres(),
          ),
        ],
      ),
    );
  }

  /// Section en-tête avec le profil utilisateur
  Widget _buildSectionEnTete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: DimensionsApplication.paddingL, // Plus besoin de SafeArea
        bottom: DimensionsApplication.paddingXL,
        left: DimensionsApplication.paddingXL,
        right: DimensionsApplication.paddingXL,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFFD0E1FF), // Bleu plus visible en bas
            Color(0xFFE1ECFF), // Bleu un peu plus soutenu au milieu
            Color(0xFFF0F4FF), // Bleu très clair en haut - même que l'AppBar
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(DimensionsApplication.radiusL),
          bottomRight: Radius.circular(DimensionsApplication.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Avatar utilisateur avec possibilité de modification
          AvatarProfilWidget(
            rayon: 65.0,
            peutModifier: true,
            surChangement: () {
              // Rafraîchir l'interface si nécessaire
              setState(() {});
            },
          ),
          const SizedBox(height: DimensionsApplication.paddingM),
          
          // Nom utilisateur
          Text(
            "Antonio Diaz",
            style: StylesTexte.titreSection.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListeOptionsParametres() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: DimensionsApplication.paddingL),
      children: [
        
        ParametreOptionWidget(
          icone: Icons.person_outline,
          titre: 'Information Personnel',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InformationsPersonnellesPage(),
              ),
            );
          },
        ),
        ParametreOptionWidget(
          icone: Icons.credit_card_outlined,
          titre: 'Moyen de paiement',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoyensPaiementPage(),
            ),
          ),
        ),
        ParametreOptionWidget(
          icone: Icons.shield_outlined,
          titre: 'Privacy & Security',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConfidentialiteSecuritePage(),
              ),
            );
          },
        ),
        ParametreOptionWidget(
          icone: Icons.headset_mic_outlined,
          titre: 'Support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupportPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // Bouton de connexion/déconnexion qui change selon l'état
        _buildBoutonConnexion(),
      ],
    );
  }

  /// Construit le bouton de connexion/déconnexion avec couleur dynamique
  /// Rouge si connecté (pour se déconnecter)
  /// Vert si non connecté (pour se connecter)
  Widget _buildBoutonConnexion() {
    return Container(
      margin: const EdgeInsets.only(
        left: DimensionsApplication.paddingXL, // Marge plus grande à gauche
        right: DimensionsApplication.paddingL,
        top: 0,
        bottom: 0,
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _estConnecte = !_estConnecte;
          });
          debugPrint(_estConnecte ? 'Connexion' : 'Déconnexion');
        },
        style: ElevatedButton.styleFrom(
          // Couleur rouge si connecté (déconnexion), vert si non connecté (connexion)
          backgroundColor: _estConnecte 
              ? CouleursApplication.erreur // Rouge pour déconnexion
              : CouleursApplication.succes, // Vert pour connexion
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: DimensionsApplication.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
          ),
          elevation: 0,
        ),
        child: Text(
          _estConnecte ? 'Se déconnecter' : 'Se connecter',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 
