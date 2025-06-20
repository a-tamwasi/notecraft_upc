# 🎯 Intégration Deepgram API - NoteCraft

## 📋 Vue d'ensemble

L'application NoteCraft utilise maintenant une **architecture hybride** qui combine le meilleur des deux mondes :

- **🚀 Deepgram** : Transcription audio (rapide, précise, sans limite de taille)
- **🧠 OpenAI** : Génération de titres intelligents et autres fonctionnalités

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────────┐    ┌─────────────────┐
│  TranscriptionView │    │ HybridTranscriptionService │    │   DeepgramService   │
│                 │────▶│                      │────▶│                 │
│                 │    │                      │    │  (Transcription) │
└─────────────────┘    │                      │    └─────────────────┘
                       │                      │
                       │                      │    ┌─────────────────┐
                       │                      │────▶│   OpenAIService     │
                       │                      │    │                 │
                       │                      │    │ (Génération titre) │
                       └──────────────────────┘    └─────────────────┘
```

## 🚀 Avantages de Deepgram

### vs OpenAI Whisper :
- ✅ **Pas de limite de taille** : Fichiers > 25MB supportés
- ✅ **Plus rapide** : Transcription en temps quasi-réel
- ✅ **Plus précis** : Spécialement optimisé pour le français
- ✅ **Formats supportés** : MP3, WAV, M4A, WEBM, OGG, FLAC
- ✅ **Smart formatting** : Ponctuation et majuscules automatiques

## ⚙️ Configuration

### 1. Obtenir les clés API

#### Deepgram (GRATUIT - $200 de crédit)
1. Créer un compte sur [Deepgram Console](https://console.deepgram.com/)
2. Générer une API Key
3. Copier la clé

#### OpenAI (pour génération de titres)
1. Aller sur [OpenAI Platform](https://platform.openai.com/api-keys)
2. Créer une API Key
3. Copier la clé

### 2. Configuration locale

```bash
# 1. Copier le fichier d'environnement
cp .env.example .env

# 2. Éditer le fichier .env
nano .env
```

```env
# Ajouter vos clés dans .env
DEEPGRAM_API_KEY=votre_vraie_cle_deepgram
OPENAI_API_KEY=votre_vraie_cle_openai
```

## 🔄 Fonctionnement

### Flux de transcription
1. **Upload fichier** → Vérification format/taille
2. **Deepgram API** → Transcription audio
3. **OpenAI API** → Génération du titre
4. **Sauvegarde** → Base de données locale

### Gestion d'erreurs
- **Fallback automatique** : Deepgram → OpenAI si échec
- **Retry logic** : Tentatives multiples en cas d'erreur réseau
- **Validation** : Vérification des réponses API

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests spécifiques Deepgram
flutter test test/services/hybrid_transcription_service_test.dart

# Tests d'intégration
flutter test test/integration/
```

## 📊 Performance

### Benchmarks typiques :
- **Fichier 10MB (10min audio)** :
  - Deepgram : ~15-30 secondes
  - OpenAI : ~60-120 secondes (si limite atteinte)

- **Précision française** :
  - Deepgram : ~95%
  - OpenAI : ~90%

## 🛠️ Développement

### Ajout d'une nouvelle fonctionnalité

```dart
// Exemple : ajouter détection de langue
final transcription = await deepgramService.transcribeAudio(
  filePath, 
  options: {
    'detect_language': true,
    'language': 'auto',
  }
);
```

### Debug mode

```dart
// Forcer l'utilisation d'OpenAI pour debug
final debugService = HybridTranscriptionService.createWithOpenAITranscription();
```

### Monitoring

```dart
// Obtenir info sur les providers utilisés
final info = hybridService.getServiceInfo();
print('Transcription: ${info['transcription_provider']}');
print('Titre: ${info['title_generation_provider']}');
```

## ⚡ Optimisations

### Formats recommandés
- **Qualité optimale** : WAV 16kHz
- **Taille optimisée** : M4A 64kbps
- **Compatibilité** : MP3 128kbps

### Paramètres Deepgram optimisés
```dart
'model': 'nova-3',           // Modèle le plus récent
'language': 'fr',            // Français spécifique
'smart_format': 'true',      // Formatage intelligent
'punctuate': 'true',         // Ponctuation auto
```

## 🔒 Sécurité

- ✅ Clés API dans variables d'environnement
- ✅ Chiffrement HTTPS pour toutes les communications
- ✅ Pas de stockage des fichiers audio côté API
- ✅ Nettoyage automatique des ressources

## 🚨 Dépannage

### Erreurs communes

#### "Clé API Deepgram non trouvée"
```bash
# Vérifier que le fichier .env existe et contient la clé
cat .env | grep DEEPGRAM
```

#### "Fichier trop volumineux"
- Limite Deepgram : 500MB (configurable)
- Compresser le fichier ou utiliser un format plus efficace

#### "Erreur réseau"
- Vérifier la connexion internet
- Le service fait automatiquement du retry

### Logs de debug
```dart
// Activer les logs détaillés
print('🚀 Début transcription...');
print('📁 Taille: ${fileSize}MB');
print('⚡ Temps: ${duration}ms');
```

## 📈 Roadmap

### À venir
- [ ] Support streaming en temps réel
- [ ] Détection automatique de langue
- [ ] Séparation des locuteurs (diarization)
- [ ] Transcription avec timestamps
- [ ] Support WebSockets pour streaming

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Ajouter des tests
4. Soumettre une PR

## 📞 Support

- **Documentation Deepgram** : [docs.deepgram.com](https://developers.deepgram.com/)
- **Issues GitHub** : Ouvrir un ticket pour bugs/features
- **Email** : contact@notecraft.app 