import 'package:flutter/foundation.dart';

/// Represents a single tip (astuce) entity.
/// This class is immutable.
@immutable
class Astuce {
  final int? id;
  final String titre;
  final String contenu;
  final String imageUrl;

  const Astuce({
    this.id,
    required this.titre,
    required this.contenu,
    required this.imageUrl,
  });

  /// Converts an [Astuce] instance into a `Map` that can be stored in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'imageUrl': imageUrl,
    };
  }

  /// Creates an [Astuce] instance from a `Map` retrieved from the database.
  factory Astuce.fromMap(Map<String, dynamic> map) {
    return Astuce(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      contenu: map['contenu'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }
} 