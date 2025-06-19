import 'package:flutter/material.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';

/// Page affichant et gérant les moyens de paiement de l'utilisateur
class MoyensPaiementPage extends StatefulWidget {
  const MoyensPaiementPage({super.key});

  @override
  State<MoyensPaiementPage> createState() => _MoyensPaiementPageState();
}

class _MoyensPaiementPageState extends State<MoyensPaiementPage> {
  // Liste des moyens de paiement (données simulées)
  final List<Map<String, dynamic>> _moyensPaiement = [
    {
      'id': '1',
      'label': 'Carte principale',
      'type': 'Visa',
      'dernierChiffres': '1234',
      'icone': Icons.credit_card,
      'couleur': Colors.blue,
    },
    {
      'id': '2',
      'label': 'Carte secondaire',
      'type': 'Mastercard',
      'dernierChiffres': '5678',
      'icone': Icons.credit_card,
      'couleur': Colors.orange,
    },
    {
      'id': '3',
      'label': 'Carte professionnelle',
      'type': 'American Express',
      'dernierChiffres': '9012',
      'icone': Icons.business_center,
      'couleur': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Moyens de paiement',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DimensionsApplication.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de la section carte principale
                Text(
                  'Carte principale',
                  style: StylesTexte.sousTitre.copyWith(
                    color: CouleursApplication.textePrincipal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: DimensionsApplication.paddingM),
                
                // Section carte bancaire stylisée
                _buildCarteBancaireStylee(),
                
                const SizedBox(height: DimensionsApplication.paddingXL),
                
                // Titre de la section moyens de paiement
                Text(
                  'Tous les moyens de paiement',
                  style: StylesTexte.sousTitre.copyWith(
                    color: CouleursApplication.textePrincipal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: DimensionsApplication.paddingM),
                
                // Liste des moyens de paiement
                _buildListeMoyensPaiement(),
                
                // Espacement pour éviter que le FAB cache le contenu
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      // Bouton flottant pour ajouter une carte
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterNouvelleCarte,
        backgroundColor: CouleursApplication.primaire,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Ajouter une carte',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Construit la carte bancaire principale stylisée
  Widget _buildCarteBancaireStylee() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        // Dégradé bleu pour un effet moderne de carte bancaire
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565C0), // Bleu foncé
            Color(0xFF42A5F5), // Bleu moyen
            Color(0xFF90CAF9), // Bleu clair
          ],
        ),
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Visa en haut à droite
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.contactless,
                  color: Colors.white,
                  size: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DimensionsApplication.paddingS,
                    vertical: DimensionsApplication.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                  ),
                  child: const Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Numéro de carte masqué
            const Text(
              '•••• •••• •••• 1234',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: DimensionsApplication.paddingM),
            
            // Nom du titulaire et date d'expiration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAIRE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'ANTONIO DIAZ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      '12/28',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la liste de tous les moyens de paiement
  Widget _buildListeMoyensPaiement() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _moyensPaiement.length,
      separatorBuilder: (context, index) => const SizedBox(height: DimensionsApplication.paddingS),
      itemBuilder: (context, index) {
        final moyen = _moyensPaiement[index];
        return _buildMoyenPaiementTile(moyen);
      },
    );
  }

  /// Construit un ListTile pour un moyen de paiement
  Widget _buildMoyenPaiementTile(Map<String, dynamic> moyen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DimensionsApplication.paddingM,
          vertical: DimensionsApplication.paddingS,
        ),
        // Icône de la banque/carte
        leading: Container(
          padding: const EdgeInsets.all(DimensionsApplication.paddingS),
          decoration: BoxDecoration(
            color: moyen['couleur'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
          ),
          child: Icon(
            moyen['icone'],
            color: moyen['couleur'],
            size: DimensionsApplication.iconeM,
          ),
        ),
        
        // Label principal
        title: Text(
          moyen['label'],
          style: StylesTexte.corps.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Sous-titre avec type et derniers chiffres
        subtitle: Text(
          '${moyen['type']} •••• ${moyen['dernierChiffres']}',
          style: StylesTexte.corpsSecondaire,
        ),
        
        // Actions : modifier et supprimer
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton modifier
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: CouleursApplication.primaire,
                size: DimensionsApplication.iconeS,
              ),
              onPressed: () => _modifierMoyenPaiement(moyen['id']),
              tooltip: 'Modifier',
            ),
            // Bouton supprimer
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: CouleursApplication.erreur,
                size: DimensionsApplication.iconeS,
              ),
              onPressed: () => _supprimerMoyenPaiement(moyen['id']),
              tooltip: 'Supprimer',
            ),
          ],
        ),
        
        // Action au tap sur toute la tuile
        onTap: () => _voirDetailsMoyenPaiement(moyen['id']),
      ),
    );
  }

  /// Ajoute une nouvelle carte (placeholder)
  void _ajouterNouvelleCarte() {
    debugPrint('Ajouter une nouvelle carte');
    
    // Affichage temporaire d'un message
    showInfo(context, 'Fonctionnalité d\'ajout de carte en développement');
  }

  /// Modifie un moyen de paiement (placeholder)
  void _modifierMoyenPaiement(String id) {
    debugPrint('Modifier le moyen de paiement: $id');
  }

  /// Supprime un moyen de paiement (placeholder)
  void _supprimerMoyenPaiement(String id) {
    debugPrint('Supprimer le moyen de paiement: $id');
    
    // Simulation de suppression avec confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Supprimer la carte',
            style: StylesTexte.sousTitre,
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette carte de paiement ?',
            style: StylesTexte.corps,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: StylesTexte.boutonSecondaire.copyWith(
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Logique de suppression réelle
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApplication.erreur,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Supprimer',
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

  /// Affiche les détails d'un moyen de paiement (placeholder)
  void _voirDetailsMoyenPaiement(String id) {
    debugPrint('Voir les détails du moyen de paiement: $id');
  }
} 