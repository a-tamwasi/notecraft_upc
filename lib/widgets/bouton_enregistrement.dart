import 'package:flutter/material.dart';
import '../src/constants/couleurs_application.dart';
import '../src/constants/dimensions_application.dart';

/// Widget de bouton d'enregistrement animé
/// Affiche un bouton circulaire qui change d'état selon l'enregistrement
class BoutonEnregistrement extends StatefulWidget {
  /// Callback appelé quand l'enregistrement démarre
  final VoidCallback? onDemarrer;

  /// Callback appelé quand l'enregistrement s'arrête
  final VoidCallback? onArreter;

  /// Indique si l'enregistrement est en cours
  final bool estEnregistrement;

  /// Indique si le bouton est désactivé
  final bool estDesactive;

  const BoutonEnregistrement({
    Key? key,
    this.onDemarrer,
    this.onArreter,
    this.estEnregistrement = false,
    this.estDesactive = false,
  }) : super(key: key);

  @override
  State<BoutonEnregistrement> createState() => _BoutonEnregistrementState();
}

class _BoutonEnregistrementState extends State<BoutonEnregistrement>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _gererAppui() {
    if (widget.estDesactive) return;

    // Animation de pression
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Appeler le bon callback
    if (widget.estEnregistrement) {
      widget.onArreter?.call();
    } else {
      widget.onDemarrer?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.estEnregistrement
                      ? CouleursApplication.erreur.withOpacity(0.3)
                      : CouleursApplication.primaire.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _gererAppui,
                customBorder: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.estDesactive
                        ? CouleursApplication.texteSecondaire
                        : widget.estEnregistrement
                            ? CouleursApplication.erreur
                            : CouleursApplication.primaire,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        widget.estEnregistrement
                            ? Icons.stop
                            : Icons.mic,
                        key: ValueKey(widget.estEnregistrement),
                        color: Colors.white,
                        size: DimensionsApplication.iconeL,
                      ),
                    ),
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