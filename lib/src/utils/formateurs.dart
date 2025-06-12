/// Classe utilitaire contenant des fonctions de formatage
/// Centralise les formatages de dates, durées, tailles de fichiers, etc.
class Formateurs {
  // Empêche l'instanciation de la classe
  Formateurs._();

  /// Formate une durée en secondes vers un format lisible (MM:SS ou HH:MM:SS)
  static String formaterDuree(int secondes) {
    if (secondes < 0) return '00:00';

    final heures = secondes ~/ 3600;
    final minutes = (secondes % 3600) ~/ 60;
    final sec = secondes % 60;

    if (heures > 0) {
      return '${heures.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    }
  }

  /// Formate une taille de fichier en bytes vers un format lisible
  static String formaterTailleFichier(int bytes) {
    if (bytes <= 0) return '0 B';

    const unites = ['B', 'KB', 'MB', 'GB'];
    int indiceUnite = 0;
    double taille = bytes.toDouble();

    while (taille >= 1024 && indiceUnite < unites.length - 1) {
      taille /= 1024;
      indiceUnite++;
    }

    // Arrondir à 2 décimales si nécessaire
    final tailleArrondie = taille >= 10 
        ? taille.toStringAsFixed(0) 
        : taille.toStringAsFixed(1);

    return '$tailleArrondie ${unites[indiceUnite]}';
  }

  /// Formate une date en format relatif (ex: "Il y a 5 minutes")
  static String formaterDateRelative(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final heures = difference.inHours;
      return 'Il y a $heures heure${heures > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final jours = difference.inDays;
      return 'Il y a $jours jour${jours > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final semaines = difference.inDays ~/ 7;
      return 'Il y a $semaines semaine${semaines > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final mois = difference.inDays ~/ 30;
      return 'Il y a $mois mois';
    } else {
      final annees = difference.inDays ~/ 365;
      return 'Il y a $annees an${annees > 1 ? 's' : ''}';
    }
  }

  /// Formate une date en format court (JJ/MM/AAAA HH:MM)
  static String formaterDateCourte(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final annee = date.year.toString();
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$jour/$mois/$annee $heure:$minute';
  }

  /// Tronque un texte avec des points de suspension si trop long
  static String tronquerTexte(String texte, int longueurMax) {
    if (texte.length <= longueurMax) return texte;
    
    return '${texte.substring(0, longueurMax - 3)}...';
  }

  /// Capitalise la première lettre d'un texte
  static String capitaliserPremiereLetttre(String texte) {
    if (texte.isEmpty) return texte;
    
    return texte[0].toUpperCase() + texte.substring(1).toLowerCase();
  }

  /// Nettoie un nom de fichier en enlevant les caractères spéciaux
  static String nettoyerNomFichier(String nom) {
    // Remplace les caractères spéciaux par des underscores
    return nom.replaceAll(RegExp(r'[^\w\s-.]'), '_')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
} 