import 'package:flutter/foundation.dart';

/// Represents a user of the application.
/// This class is immutable.
@immutable
class Utilisateur {
  final int? id;
  final String prenom;
  final String email;
  final DateTime dateInscription;
  final String? imageProfil; // Chemin vers l'image de profil

  const Utilisateur({
    this.id,
    required this.prenom,
    required this.email,
    required this.dateInscription,
    this.imageProfil,
  });

  /// Converts an [Utilisateur] instance into a `Map`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'email': email,
      'dateInscription': dateInscription.toIso8601String(),
      'imageProfil': imageProfil,
    };
  }

  /// Creates an [Utilisateur] instance from a `Map`.
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] as int?,
      prenom: map['prenom'] as String,
      email: map['email'] as String,
      dateInscription: DateTime.parse(map['dateInscription'] as String),
      imageProfil: map['imageProfil'] as String?,
    );
  }

  /// Crée une copie de cet utilisateur avec des champs modifiés
  Utilisateur copyWith({
    int? id,
    String? prenom,
    String? email,
    DateTime? dateInscription,
    String? imageProfil,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      dateInscription: dateInscription ?? this.dateInscription,
      imageProfil: imageProfil ?? this.imageProfil,
    );
  }
} 