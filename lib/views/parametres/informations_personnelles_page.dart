import 'package:flutter/material.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';

// --- //
// 1. PAGE DES INFORMATIONS PERSONNELLES
// --- //

/// Page affichant et permettant de modifier les informations personnelles de l'utilisateur
class InformationsPersonnellesPage extends StatefulWidget {
  const InformationsPersonnellesPage({super.key});

  @override
  State<InformationsPersonnellesPage> createState() => _InformationsPersonnellesPageState();
}

class _InformationsPersonnellesPageState extends State<InformationsPersonnellesPage> {
  // État de chargement des données
  bool _estEnChargement = true;
  
  // Données utilisateur (simulées)
  String _nomComplet = "Antonio Diaz";
  String _email = "antonio.diaz@example.com";
  
  // Contrôleur pour le dialog de modification
  final TextEditingController _controleurNom = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerDonneesUtilisateur();
  }

  @override
  void dispose() {
    _controleurNom.dispose();
    super.dispose();
  }

  /// Simule le chargement des données utilisateur
  Future<void> _chargerDonneesUtilisateur() async {
    // TODO: Remplacer par la vraie logique de récupération depuis Firestore
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    
    // Vérifier si le widget est toujours monté après l'opération asynchrone
    if (!mounted) return;
    
    setState(() {
      _estEnChargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Informations personnelles',
          style: TextStyle(
            color: CouleursApplication.textePrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: CouleursApplication.textePrincipal),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _estEnChargement 
            ? _buildLoader()
            : _buildContenuInformations(),
      ),
    );
  }

  // --- //
  // 2. AFFICHAGE DU LOADER
  // --- //

  /// Affiche un loader pendant le chargement des données
  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: CouleursApplication.primaire,
          ),
          SizedBox(height: DimensionsApplication.paddingM),
          Text(
            'Chargement des informations...',
            style: StylesTexte.corpsSecondaire,
          ),
        ],
      ),
    );
  }

  // --- //
  // 3. CONTENU PRINCIPAL DES INFORMATIONS
  // --- //

  /// Affiche le contenu principal avec les informations utilisateur
  Widget _buildContenuInformations() {
    return Padding(
      padding: const EdgeInsets.all(DimensionsApplication.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          Text(
            'Informations du compte',
            style: StylesTexte.sousTitre.copyWith(
              color: CouleursApplication.textePrincipal,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DimensionsApplication.paddingL),
          
          // Card contenant les informations
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
            ),
            child: Column(
              children: [
                // Nom complet avec bouton modifier
                _buildListTileNom(),
                
                // Divider
                const Divider(
                  height: 1,
                  color: CouleursApplication.bordure,
                ),
                
                // Email (non modifiable)
                _buildListTileEmail(),
              ],
            ),
          ),
          
          const SizedBox(height: DimensionsApplication.paddingL),
          
          // Note explicative
          Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingM),
            decoration: BoxDecoration(
              color: CouleursApplication.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
              border: Border.all(
                color: CouleursApplication.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: CouleursApplication.info,
                  size: DimensionsApplication.iconeS,
                ),
                const SizedBox(width: DimensionsApplication.paddingS),
                Expanded(
                  child: Text(
                    'Votre adresse e-mail ne peut pas être modifiée. Contactez le support si nécessaire.',
                    style: StylesTexte.corpsPetit.copyWith(
                      color: CouleursApplication.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- //
  // 4. LISTILES POUR LES INFORMATIONS
  // --- //

  /// ListTile pour le nom avec bouton de modification
  Widget _buildListTileNom() {
    return ListTile(
      leading: const Icon(
        Icons.person_outline,
        color: CouleursApplication.texteSecondaire,
      ),
      title: const Text(
        'Nom complet',
        style: StylesTexte.labelFormulaire,
      ),
      subtitle: Text(
        _nomComplet,
        style: StylesTexte.corps.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          color: CouleursApplication.primaire,
        ),
        onPressed: _ouvrirDialogModificationNom,
        tooltip: 'Modifier le nom',
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.paddingM,
        vertical: DimensionsApplication.paddingS,
      ),
    );
  }

  /// ListTile pour l'email (lecture seule)
  Widget _buildListTileEmail() {
    return ListTile(
      leading: const Icon(
        Icons.email_outlined,
        color: CouleursApplication.texteSecondaire,
      ),
      title: const Text(
        'Adresse e-mail',
        style: StylesTexte.labelFormulaire,
      ),
      subtitle: Text(
        _email,
        style: StylesTexte.corps.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.lock_outline,
        color: CouleursApplication.texteSecondaire,
        size: DimensionsApplication.iconeS,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.paddingM,
        vertical: DimensionsApplication.paddingS,
      ),
    );
  }

  // --- //
  // 5. DIALOG DE MODIFICATION DU NOM
  // --- //

  /// Ouvre le dialog pour modifier le nom de l'utilisateur
  void _ouvrirDialogModificationNom() {
    _controleurNom.text = _nomComplet;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Modifier le nom',
            style: StylesTexte.sousTitre,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controleurNom,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  labelStyle: StylesTexte.labelFormulaire,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                    borderSide: const BorderSide(color: CouleursApplication.primaire),
                  ),
                ),
                style: StylesTexte.corps,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: StylesTexte.boutonSecondaire.copyWith(
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _sauvegarderNouveauNom();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApplication.primaire,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Sauvegarder',
                style: StylesTexte.boutonSecondaire.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- //
  // 6. SAUVEGARDE DU NOUVEAU NOM
  // --- //

  /// Sauvegarde le nouveau nom (placeholder pour Firebase)
  void _sauvegarderNouveauNom() {
    final nouveauNom = _controleurNom.text.trim();
    
    if (nouveauNom.isNotEmpty && nouveauNom != _nomComplet) {
      // Vérifier si le widget est toujours monté avant de mettre à jour l'état
      if (!mounted) return;
      
      setState(() {
        _nomComplet = nouveauNom;
      });
      
      // TODO: Intégrer avec Firebase
      // await FirebaseAuth.instance.currentUser?.updateDisplayName(nouveauNom);
      // await Firestore.collection('users').doc(uid).update({'nom': nouveauNom});
      
      // Affichage d'un message de succès
      showSuccess(context, 'Nom mis à jour avec succès');
    }
  }
}
