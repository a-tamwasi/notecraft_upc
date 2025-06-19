import 'package:flutter/material.dart';
import '../../src/constants/couleurs_application.dart';
import '../../src/constants/dimensions_application.dart';
import '../../src/constants/styles_texte.dart';
import '../../src/utils/error_handler.dart';
import '../../services/credit_service.dart';

// --- //
// 1. DÉCLARATION DU WIDGET DE LA PAGE D'ABONNEMENT
// --- //

/// Présente les offres d'abonnement et permet à l'utilisateur de souscrire.
///
/// Cette page est actuellement un `StatelessWidget`. Elle pourrait devenir
/// un `StatefulWidget` si elle devait, par exemple, charger les détails des offres
/// depuis un serveur ou gérer la sélection interactive des plans.
class PageAbonnement extends StatelessWidget {
  const PageAbonnement({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyContent = Padding(
      padding: const EdgeInsets.all(DimensionsApplication.paddingL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.shopping_cart_checkout,
              size: 80,
              color: CouleursApplication.primaire,
            ),
            const SizedBox(height: DimensionsApplication.margeGrande),
            Text(
              'Bientôt disponible !',
              style: StylesTexte.titrePrincipal,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DimensionsApplication.margeMoyenne),
            Text(
              'La boutique pour recharger vos minutes de transcription sera bientôt là.',
              style: StylesTexte.corps,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DimensionsApplication.margeSection),
            // Bouton pour simuler l'achat de 60 minutes
            ElevatedButton(
              onPressed: () {
                // Utilise le service de crédits pour ajouter 60 minutes (3600 secondes)
                creditService.addCredits(3600);

                // Affiche une confirmation à l'utilisateur
                showSuccess(context, '60 minutes ont été ajoutées à votre compte !');

                // L'ancienne logique de pop est retirée car la navigation est gérée différemment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApplication.primaire,
                padding: const EdgeInsets.symmetric(
                    vertical: DimensionsApplication.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DimensionsApplication.radiusL),
                ),
              ),
              child: Text(
                'Simuler l\'ajout de 60 minutes',
                style: StylesTexte.corps.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    // Si la page peut être "popped" (c'est-à-dire qu'elle n'est pas la racine),
    // on l'affiche avec un Scaffold pour avoir une AppBar et un fond.
    if (Navigator.of(context).canPop()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acheter des crédits'),
          backgroundColor: CouleursApplication.fondPrincipal,
          elevation: 0,
        ),
        backgroundColor: CouleursApplication.fondPrincipal,
        body: bodyContent,
      );
    }

    // Sinon, on retourne juste le contenu, car elle est probablement dans un autre Scaffold (ex: BottomNav).
    return Center(child: bodyContent);
  }
} 