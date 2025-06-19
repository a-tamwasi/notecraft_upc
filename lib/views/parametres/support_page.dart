import 'package:flutter/material.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';

// --- //
// 1. PAGE SUPPORT
// --- //

/// Page d'aide et de support pour les utilisateurs
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Contrôleurs pour les champs de texte des dialogs
  final TextEditingController _bugController = TextEditingController();
  final TextEditingController _avisController = TextEditingController();

  // Liste des questions fréquemment posées (FAQ)
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Comment enregistrer une note vocale ?',
      'reponse': 'Appuyez sur le bouton d\'enregistrement rouge sur l\'écran principal. Maintenez-le enfoncé pour enregistrer votre note. Relâchez pour arrêter l\'enregistrement. Votre note sera automatiquement transcrite.',
    },
    {
      'question': 'Puis-je modifier une transcription ?',
      'reponse': 'Oui, après la transcription, vous pouvez appuyer sur l\'icône d\'édition pour corriger ou modifier le texte transcrit. Les modifications seront sauvegardées automatiquement.',
    },
    {
      'question': 'Comment exporter mes notes en PDF ?',
      'reponse': 'Dans l\'historique de vos notes, appuyez sur une note puis sélectionnez l\'option "Exporter en PDF". Vous pourrez ensuite partager ou sauvegarder le fichier PDF généré.',
    },
    {
      'question': 'Mes notes sont-elles sauvegardées dans le cloud ?',
      'reponse': 'Oui, toutes vos notes sont automatiquement synchronisées avec votre compte. Vous pouvez y accéder depuis n\'importe quel appareil en vous connectant avec vos identifiants.',
    },
    {
      'question': 'Comment améliorer la qualité de transcription ?',
      'reponse': 'Pour une meilleure transcription, parlez clairement, évitez les bruits de fond, tenez votre appareil près de votre bouche et assurez-vous d\'avoir une bonne connexion internet.',
    },
  ];

  @override
  void dispose() {
    // Libération des contrôleurs
    _bugController.dispose();
    _avisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Support',
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
          child: Column(
            children: [
              // Section FAQ
              _buildSectionFAQ(),
              
              const SizedBox(height: DimensionsApplication.paddingXL),
              
              // Section Actions de support
              _buildSectionActionsSupport(),
              
              const SizedBox(height: DimensionsApplication.paddingXL),
              
              // Footer avec informations de version
              _buildFooterVersion(),
              
              const SizedBox(height: DimensionsApplication.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  // --- //
  // 2. SECTION FAQ (FOIRE AUX QUESTIONS)
  // --- //

  /// Construit la section FAQ avec les questions-réponses
  Widget _buildSectionFAQ() {
    return Column(
      children: [
        // Titre de la section FAQ
        Padding(
          padding: const EdgeInsets.all(DimensionsApplication.paddingL),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Questions fréquentes',
              style: StylesTexte.titreSection.copyWith(
                color: CouleursApplication.textePrincipal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        // Liste des questions FAQ
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: DimensionsApplication.paddingM),
          itemCount: _faqItems.length,
          itemBuilder: (context, index) {
            final faqItem = _faqItems[index];
            return _buildFAQExpansionTile(faqItem);
          },
        ),
      ],
    );
  }

  /// Construit un ExpansionTile pour une question FAQ
  Widget _buildFAQExpansionTile(Map<String, String> faqItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: DimensionsApplication.paddingS),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
      ),
      child: ExpansionTile(
        title: Text(
          faqItem['question']!,
          style: StylesTexte.corps.copyWith(
            fontWeight: FontWeight.w600,
            color: CouleursApplication.textePrincipal,
          ),
        ),
        iconColor: CouleursApplication.primaire,
        collapsedIconColor: CouleursApplication.texteSecondaire,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: DimensionsApplication.paddingL,
              right: DimensionsApplication.paddingL,
              bottom: DimensionsApplication.paddingL,
            ),
            child: Text(
              faqItem['reponse']!,
              style: StylesTexte.corpsSecondaire.copyWith(
                height: 1.5, // Espacement entre les lignes
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- //
  // 3. SECTION ACTIONS DE SUPPORT
  // --- //

  /// Construit la section avec les actions de support
  Widget _buildSectionActionsSupport() {
    return Column(
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensionsApplication.paddingL),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Besoin d\'aide ?',
              style: StylesTexte.titreSection.copyWith(
                color: CouleursApplication.textePrincipal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: DimensionsApplication.paddingM),
        
        // Action : Envoyer un e-mail
        _buildActionTile(
          icone: Icons.email_outlined,
          couleurIcone: CouleursApplication.primaire,
          titre: 'Envoyer un e-mail',
          description: 'Contactez notre équipe support directement',
          onTap: _envoyerEmail,
        ),
        
        // Action : Signaler un bug
        _buildActionTile(
          icone: Icons.bug_report_outlined,
          couleurIcone: CouleursApplication.erreur,
          titre: 'Signaler un bug',
          description: 'Rapportez un problème technique',
          onTap: _signalerBug,
        ),
        
        // Action : Donner un avis
        _buildActionTile(
          icone: Icons.lightbulb_outline,
          couleurIcone: CouleursApplication.succes,
          titre: 'Donner un avis',
          description: 'Partagez vos suggestions d\'amélioration',
          onTap: _donnerAvis,
        ),
      ],
    );
  }

  /// Construit un ListTile pour une action de support
  Widget _buildActionTile({
    required IconData icone,
    required Color couleurIcone,
    required String titre,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.paddingL,
        vertical: DimensionsApplication.paddingS,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.radiusM),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(DimensionsApplication.paddingS),
            decoration: BoxDecoration(
              color: couleurIcone.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
            ),
            child: Icon(
              icone,
              color: couleurIcone,
              size: DimensionsApplication.iconeM,
            ),
          ),
          title: Text(
            titre,
            style: StylesTexte.corps.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            description,
            style: StylesTexte.corpsSecondaire,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CouleursApplication.texteSecondaire,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // --- //
  // 4. FOOTER VERSION ET LIENS
  // --- //

  /// Construit le footer avec les informations de version et liens
  Widget _buildFooterVersion() {
    return Container(
      padding: const EdgeInsets.all(DimensionsApplication.paddingL),
      child: Column(
        children: [
          // Séparateur visuel
          Divider(
            color: CouleursApplication.texteSecondaire.withOpacity(0.3),
          ),
          
          const SizedBox(height: DimensionsApplication.paddingM),
          
          // Informations de version et liens
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Version de l'application
              Text(
                'Version 1.0.0',
                style: StylesTexte.corpsSecondaire.copyWith(
                  fontSize: 12,
                ),
              ),
              
              // Séparateur
              Text(
                ' • ',
                style: StylesTexte.corpsSecondaire.copyWith(
                  fontSize: 12,
                ),
              ),
              
              // Lien CGU
              GestureDetector(
                onTap: _ouvrirCGU,
                child: Text(
                  'CGU',
                  style: StylesTexte.corpsSecondaire.copyWith(
                    fontSize: 12,
                    color: CouleursApplication.primaire,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              // Séparateur
              Text(
                ' • ',
                style: StylesTexte.corpsSecondaire.copyWith(
                  fontSize: 12,
                ),
              ),
              
              // Lien Confidentialité
              GestureDetector(
                onTap: _ouvrirConfidentialite,
                child: Text(
                  'Confidentialité',
                  style: StylesTexte.corpsSecondaire.copyWith(
                    fontSize: 12,
                    color: CouleursApplication.primaire,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- //
  // 5. ACTIONS ET DIALOGS
  // --- //

  /// Action pour envoyer un e-mail (placeholder)
  void _envoyerEmail() {
    // TODO: Implémenter l'ouverture de l'application e-mail avec mailto:
    // TODO: Utiliser url_launcher pour ouvrir mailto:support@notecraft.com
    debugPrint('Envoyer un e-mail de support');
    
    showInfo(context, 'Ouverture de l\'application e-mail...');
  }

  /// Action pour signaler un bug avec dialog
  void _signalerBug() {
    _bugController.clear(); // Vider le champ
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Signaler un bug',
            style: StylesTexte.sousTitre,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Décrivez le problème rencontré pour nous aider à l\'améliorer :',
                style: StylesTexte.corps,
              ),
              const SizedBox(height: DimensionsApplication.paddingM),
              TextField(
                controller: _bugController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ex: L\'application se ferme quand je clique sur...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                  ),
                  contentPadding: const EdgeInsets.all(DimensionsApplication.paddingM),
                ),
              ),
            ],
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
                _envoyerRapportBug(_bugController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApplication.erreur,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Envoyer',
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

  /// Action pour donner un avis avec dialog
  void _donnerAvis() {
    _avisController.clear(); // Vider le champ
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Donner un avis',
            style: StylesTexte.sousTitre,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Partagez vos suggestions pour améliorer NoteCraft :',
                style: StylesTexte.corps,
              ),
              const SizedBox(height: DimensionsApplication.paddingM),
              TextField(
                controller: _avisController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ex: Il serait génial d\'avoir une fonction pour...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionsApplication.radiusS),
                  ),
                  contentPadding: const EdgeInsets.all(DimensionsApplication.paddingM),
                ),
              ),
            ],
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
                _envoyerAvis(_avisController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApplication.succes,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Envoyer',
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

  /// Traite l'envoi du rapport de bug
  void _envoyerRapportBug(String description) {
    if (description.trim().isEmpty) {
      showError(context, 'Veuillez décrire le problème rencontré');
      return;
    }
    
    // TODO: Envoyer le rapport de bug à l'équipe de développement
    // TODO: Inclure les informations système (version OS, version app, etc.)
    debugPrint('Rapport de bug: $description');
    
    showSuccess(context, 'Merci ! Votre rapport de bug a été envoyé');
  }

  /// Traite l'envoi de l'avis utilisateur
  void _envoyerAvis(String avis) {
    if (avis.trim().isEmpty) {
      showError(context, 'Veuillez saisir votre avis ou suggestion');
      return;
    }
    
    // TODO: Envoyer l'avis à l'équipe produit
    // TODO: Sauvegarder dans une base de données feedback
    debugPrint('Avis utilisateur: $avis');
    
    showSuccess(context, 'Merci pour votre retour ! Cela nous aide à nous améliorer');
  }

  /// Ouvre les Conditions Générales d'Utilisation (placeholder)
  void _ouvrirCGU() {
    // TODO: Ouvrir les CGU dans une WebView ou navigateur
    debugPrint('Ouvrir les CGU');
    
    showInfo(context, 'Ouverture des Conditions Générales d\'Utilisation...');
  }

  /// Ouvre la politique de confidentialité (placeholder)
  void _ouvrirConfidentialite() {
    // TODO: Ouvrir la politique de confidentialité dans une WebView
    debugPrint('Ouvrir la politique de confidentialité');
    
    showInfo(context, 'Ouverture de la politique de confidentialité...');
  }

  // --- //
  // 6. MÉTHODES UTILITAIRES
  // --- //
  
  // Plus de méthodes utilitaires nécessaires - l'affichage des messages
  // est maintenant géré par le gestionnaire d'erreurs centralisé
} 