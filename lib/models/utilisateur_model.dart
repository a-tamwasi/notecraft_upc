import 'package:flutter/foundation.dart';

/// Represents a user of the application.
/// This class is immutable.
@immutable
class Utilisateur {
  final int? id;
  final String prenom;
  final String email;
  final DateTime dateInscription;

  const Utilisateur({
    this.id,
    required this.prenom,
    required this.email,
    required this.dateInscription,
  });

  /// Converts an [Utilisateur] instance into a `Map`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'email': email,
      'dateInscription': dateInscription.toIso8601String(),
    };
  }

  /// Creates an [Utilisateur] instance from a `Map`.
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] as int?,
      prenom: map['prenom'] as String,
      email: map['email'] as String,
      dateInscription: DateTime.parse(map['dateInscription'] as String),
    );
  }
} 