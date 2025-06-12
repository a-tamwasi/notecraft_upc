/// Modèle représentant une transcription audio
/// Contient les données d'une conversion audio vers texte
class TranscriptionModel {
  /// Identifiant unique de la transcription
  final String id;

  /// Texte transcrit depuis l'audio
  final String texte;

  /// Durée de l'audio en secondes
  final double dureeAudio;

  /// Date et heure de la transcription
  final DateTime dateTranscription;

  /// Langue de la transcription
  final String langue;

  /// Nom du fichier audio source (optionnel)
  final String? nomFichierSource;

  /// Taille du fichier audio en bytes (optionnel)
  final int? tailleFichier;

  /// Constructeur
  TranscriptionModel({
    required this.id,
    required this.texte,
    required this.dureeAudio,
    required this.dateTranscription,
    required this.langue,
    this.nomFichierSource,
    this.tailleFichier,
  });

  /// Crée une instance depuis un JSON
  /// TODO: Implémenter la désérialisation depuis la réponse API
  factory TranscriptionModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('À implémenter lors de l\'intégration API');
  }

  /// Convertit l'instance en JSON
  /// TODO: Implémenter la sérialisation pour la sauvegarde locale
  Map<String, dynamic> toJson() {
    throw UnimplementedError('À implémenter lors de l\'intégration de la persistance');
  }

  /// Crée une copie avec des modifications
  TranscriptionModel copyWith({
    String? id,
    String? texte,
    double? dureeAudio,
    DateTime? dateTranscription,
    String? langue,
    String? nomFichierSource,
    int? tailleFichier,
  }) {
    return TranscriptionModel(
      id: id ?? this.id,
      texte: texte ?? this.texte,
      dureeAudio: dureeAudio ?? this.dureeAudio,
      dateTranscription: dateTranscription ?? this.dateTranscription,
      langue: langue ?? this.langue,
      nomFichierSource: nomFichierSource ?? this.nomFichierSource,
      tailleFichier: tailleFichier ?? this.tailleFichier,
    );
  }

  @override
  String toString() {
    return 'TranscriptionModel(id: $id, texte: ${texte.substring(0, texte.length > 50 ? 50 : texte.length)}..., dureeAudio: $dureeAudio, dateTranscription: $dateTranscription)';
  }
} 