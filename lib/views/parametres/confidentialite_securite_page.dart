import 'package:flutter/material.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';

// --- //
// 1. PAGE CONFIDENTIALITÉ & SÉCURITÉ
// --- //

/// Page permettant de gérer les paramètres de confidentialité et sécurité
class ConfidentialiteSecuritePage extends StatefulWidget {
  const ConfidentialiteSecuritePage({super.key});

  @override
  State<ConfidentialiteSecuritePage> createState() => _ConfidentialiteSecuritePageState();
}

class _ConfidentialiteSecuritePageState extends State<ConfidentialiteSecuritePage> {
  // État du switch pour les analytics anonymes
  bool _analyticsAnonymes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confidentialité & Sécurité',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: DimensionsApplication.paddingM),
          children: [
            // Section Sécurité du compte
            _buildSectionSecuriteCompte(),
            
            // Séparateur entre les sections
            _buildSeparateur(),
            
            // Section Confidentialité
            _buildSectionConfidentialite(),
            
            // Séparateur entre les sections
            _buildSeparateur(),
            
            // Section Gestion du compte
            _buildSectionGestionCompte(),
          ],
        ),
      ),
    );
  }

  // --- //
  // 2. SECTION SÉCURITÉ DU COMPTE
  // --- //

  /// Construit la section des paramètres de sécurité du compte
  Widget _buildSectionSecuriteCompte() {
    return Column(
      children: [
        // Titre de section
        _buildTitreSection('Sécurité du compte'),
        
        // Option : Changer le mot de passe
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: CouleursApplication.primaire.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: CouleursApplication.primaire,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            'Changer le mot de passe',
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Modifiez votre mot de passe pour sécuriser votre compte',
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CouleursApplication.texteSecondaire,
          ),
          onTap: _changerMotDePasse,
        ),
        
        // Option : Déconnexion des appareils
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: CouleursApplication.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: const Icon(
              Icons.devices_outlined,
              color: CouleursApplication.info,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            'Déconnexion appareils',
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Déconnectez-vous de tous vos autres appareils',
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CouleursApplication.texteSecondaire,
          ),
          onTap: _deconnexionAppareils,
        ),
      ],
    );
  }

  // --- //
  // 3. SECTION CONFIDENTIALITÉ
  // --- //

  /// Construit la section des paramètres de confidentialité
  Widget _buildSectionConfidentialite() {
    return Column(
      children: [
        // Titre de section
        _buildTitreSection('Confidentialité'),
        
        // Option : Analytics anonymes avec Switch
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: CouleursApplication.succes.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: CouleursApplication.succes,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            'Analytics anonymes',
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Aide à améliorer l\'application en partageant des données anonymes',
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: Switch(
            value: _analyticsAnonymes,
            onChanged: _changerAnalyticsAnonymes,
            activeColor: CouleursApplication.primaire,
          ),
        ),
        
        // Option : Politique de confidentialité
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: CouleursApplication.texteSecondaire.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: CouleursApplication.texteSecondaire,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            'Politique de confidentialité',
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Consultez notre politique de protection des données',
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CouleursApplication.texteSecondaire,
          ),
          onTap: _voirPolitiqueConfidentialite,
        ),
      ],
    );
  }

  // --- //
  // 4. SECTION GESTION DU COMPTE
  // --- //

  /// Construit la section de gestion du compte (actions critiques)
  Widget _buildSectionGestionCompte() {
    return Column(
      children: [
        // Titre de section
        _buildTitreSection('Gestion du compte'),
        
        // Option : Supprimer mon compte (en rouge)
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: CouleursApplication.erreur.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: const Icon(
              Icons.delete_forever_outlined,
              color: CouleursApplication.erreur,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            'Supprimer mon compte',
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w500,
              color: CouleursApplication.erreur, // Texte en rouge
            ),
          ),
          subtitle: const Text(
            'Suppression définitive de toutes vos données',
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CouleursApplication.erreur, // Chevron en rouge aussi
          ),
          onTap: _supprimerCompte,
        ),
      ],
    );
  }

  // --- //
  // 5. WIDGETS UTILITAIRES
  // --- //

  /// Construit un titre de section
  Widget _buildTitreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.paddingL,
        vertical: DimensionsApplication.paddingM,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titre,
          style: StylesTexte.sousTitre.copyWith(
            color: CouleursApplication.textePrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Construit un séparateur entre les sections
  Widget _buildSeparateur() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DimensionsApplication.paddingL),
      child: Divider(
        thickness: 1,
        color: CouleursApplication.texteSecondaire.withOpacity(0.2),
        indent: DimensionsApplication.paddingL,
        endIndent: DimensionsApplication.paddingL,
      ),
    );
  }

  // --- //
  // 6. ACTIONS (PLACEHOLDERS)
  // --- //

  /// Action pour changer le mot de passe (placeholder)
  void _changerMotDePasse() {
    // TODO: Ouvrir une page ou un dialog pour changer le mot de passe
    // TODO: Vérifier l'ancien mot de passe et demander le nouveau
    debugPrint('Changer le mot de passe');
    
    showInfo(context, 'Fonctionnalité de changement de mot de passe en développement');
  }

  /// Action pour déconnecter tous les appareils (placeholder)
  void _deconnexionAppareils() {
    // TODO: Appeler l'API pour déconnecter tous les autres appareils
    // TODO: Afficher une confirmation avant l'action
    debugPrint('Déconnexion des appareils');
    
    _afficherDialogConfirmation(
      'Déconnexion des appareils',
      'Êtes-vous sûr de vouloir vous déconnecter de tous vos autres appareils ?',
      () {
        // TODO: Logique de déconnexion réelle
        showSuccess(context, 'Déconnexion de tous les appareils effectuée');
      },
    );
  }

  /// Action pour modifier le paramètre d'analytics anonymes
  void _changerAnalyticsAnonymes(bool nouvelleValeur) {
    setState(() {
      _analyticsAnonymes = nouvelleValeur;
    });
    
    // TODO: Sauvegarder la préférence en base de données
    // TODO: Activer/désactiver les analytics dans l'application
    debugPrint('Analytics anonymes: $_analyticsAnonymes');
    
    if (_analyticsAnonymes) {
      showSuccess(context, 'Analytics anonymes activées');
    } else {
      showInfo(context, 'Analytics anonymes désactivées');
    }
  }

  /// Action pour voir la politique de confidentialité (placeholder)
  void _voirPolitiqueConfidentialite() {
    // TODO: Ouvrir une WebView ou une page dédiée avec la politique
    // TODO: Charger le contenu depuis un serveur ou un asset local
    debugPrint('Voir la politique de confidentialité');
    
    showInfo(context, 'Ouverture de la politique de confidentialité...');
  }

  /// Action pour supprimer le compte (placeholder)
  void _supprimerCompte() {
    // TODO: Demander confirmation avec mot de passe
    // TODO: Expliquer les conséquences de la suppression
    debugPrint('Supprimer le compte');
    
    _afficherDialogConfirmation(
      'Supprimer mon compte',
      'Cette action est irréversible. Toutes vos données seront définitivement supprimées.\n\nÊtes-vous absolument sûr ?',
      () {
        // TODO: Logique de suppression de compte réelle
        showError(context, 'Suppression du compte en cours...');
      },
      couleurBouton: CouleursApplication.erreur,
      texteBouton: 'Supprimer définitivement',
    );
  }

  // --- //
  // 7. MÉTHODES UTILITAIRES
  // --- //

  // L'affichage des messages est maintenant géré par le gestionnaire d'erreurs centralisé

  /// Affiche un dialog de confirmation pour les actions critiques
  void _afficherDialogConfirmation(
    String titre,
    String contenu,
    VoidCallback onConfirmer, {
    Color couleurBouton = CouleursApplication.primaire,
    String texteBouton = 'Confirmer',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titre,
            style: StylesTexte.sousTitre,
          ),
          content: Text(
            contenu,
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
                onConfirmer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: couleurBouton,
                foregroundColor: Colors.white,
              ),
              child: Text(
                texteBouton,
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
} 