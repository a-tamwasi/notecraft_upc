import 'package:flutter_test/flutter_test.dart';
import 'package:notecraft_upc/src/utils/formateurs.dart';

void main() {
  group('Formateurs', () {
    group('formaterDuree', () {
      test('devrait formater correctement les secondes', () {
        expect(Formateurs.formaterDuree(0), '00:00');
        expect(Formateurs.formaterDuree(30), '00:30');
        expect(Formateurs.formaterDuree(59), '00:59');
      });

      test('devrait formater correctement les minutes', () {
        expect(Formateurs.formaterDuree(60), '01:00');
        expect(Formateurs.formaterDuree(90), '01:30');
        expect(Formateurs.formaterDuree(3599), '59:59');
      });

      test('devrait formater correctement les heures', () {
        expect(Formateurs.formaterDuree(3600), '01:00:00');
        expect(Formateurs.formaterDuree(3661), '01:01:01');
        expect(Formateurs.formaterDuree(7200), '02:00:00');
      });

      test('devrait gérer les valeurs négatives', () {
        expect(Formateurs.formaterDuree(-10), '00:00');
      });
    });

    group('formaterTailleFichier', () {
      test('devrait formater correctement les bytes', () {
        expect(Formateurs.formaterTailleFichier(0), '0 B');
        expect(Formateurs.formaterTailleFichier(100), '100 B');
        expect(Formateurs.formaterTailleFichier(1023), '1023 B');
      });

      test('devrait formater correctement les KB', () {
        expect(Formateurs.formaterTailleFichier(1024), '1.0 KB');
        expect(Formateurs.formaterTailleFichier(1536), '1.5 KB');
        expect(Formateurs.formaterTailleFichier(10240), '10 KB');
      });

      test('devrait formater correctement les MB', () {
        expect(Formateurs.formaterTailleFichier(1048576), '1.0 MB');
        expect(Formateurs.formaterTailleFichier(5242880), '5.0 MB');
        expect(Formateurs.formaterTailleFichier(10485760), '10 MB');
      });

      test('devrait formater correctement les GB', () {
        expect(Formateurs.formaterTailleFichier(1073741824), '1.0 GB');
        expect(Formateurs.formaterTailleFichier(2147483648), '2.0 GB');
      });
    });

    group('tronquerTexte', () {
      test('devrait retourner le texte original si plus court que la limite', () {
        expect(Formateurs.tronquerTexte('Bonjour', 10), 'Bonjour');
        expect(Formateurs.tronquerTexte('Test', 4), 'Test');
      });

      test('devrait tronquer avec des points de suspension', () {
        expect(Formateurs.tronquerTexte('Bonjour le monde', 10), 'Bonjour...');
        expect(Formateurs.tronquerTexte('Flutter est génial', 12), 'Flutter e...');
      });
    });

    group('capitaliserPremiereLetttre', () {
      test('devrait capitaliser la première lettre', () {
        expect(Formateurs.capitaliserPremiereLetttre('bonjour'), 'Bonjour');
        expect(Formateurs.capitaliserPremiereLetttre('FLUTTER'), 'Flutter');
        expect(Formateurs.capitaliserPremiereLetttre('test'), 'Test');
      });

      test('devrait gérer les chaînes vides', () {
        expect(Formateurs.capitaliserPremiereLetttre(''), '');
      });
    });

    group('nettoyerNomFichier', () {
      test('devrait nettoyer les caractères spéciaux', () {
        expect(Formateurs.nettoyerNomFichier('mon*fichier.txt'), 'mon_fichier.txt');
        expect(Formateurs.nettoyerNomFichier('test@#\$%.mp3'), 'test_.mp3');
        expect(Formateurs.nettoyerNomFichier('audio 2024.wav'), 'audio_2024.wav');
      });

      test('devrait conserver les caractères valides', () {
        expect(Formateurs.nettoyerNomFichier('mon-fichier_2024.txt'), 'mon-fichier_2024.txt');
        expect(Formateurs.nettoyerNomFichier('audio.mp3'), 'audio.mp3');
      });
    });
  });
} 