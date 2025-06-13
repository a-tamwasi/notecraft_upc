import 'package:flutter/foundation.dart';
import 'package:notecraft_upc/data/database/database_service.dart';

/// Represents a single note/transcription entity.
/// This class is immutable.
@immutable
class Note {
  final int? id;
  final String titre;
  final String contenu;
  final DateTime dateCreation;
  final String cheminAudio;
  final String langue;

  const Note({
    this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
    required this.cheminAudio,
    required this.langue,
  });

  /// Creates a copy of the current Note with the given fields replaced with the new values.
  Note copyWith({
    int? id,
    String? titre,
    String? contenu,
    DateTime? dateCreation,
    String? cheminAudio,
    String? langue,
  }) {
    return Note(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      cheminAudio: cheminAudio ?? this.cheminAudio,
      langue: langue ?? this.langue,
    );
  }

  /// Converts a [Note] instance into a `Map` that can be stored in the database.
  /// The `id` is included, and if it's `null`, SQLite will treat it as an autoincrementing field.
  Map<String, dynamic> toMap() {
    return {
      NoteFields.id: id,
      NoteFields.titre: titre,
      NoteFields.contenu: contenu,
      NoteFields.dateCreation: dateCreation.toIso8601String(),
      'cheminAudio': cheminAudio,
      'langue': langue,
    };
  }

  /// Creates a [Note] instance from a `Map` retrieved from the database.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map[NoteFields.id] as int?,
      titre: map[NoteFields.titre] as String,
      contenu: map[NoteFields.contenu] as String,
      dateCreation: DateTime.parse(map[NoteFields.dateCreation] as String),
      cheminAudio: map['cheminAudio'] as String,
      langue: map['langue'] as String,
    );
  }
} 