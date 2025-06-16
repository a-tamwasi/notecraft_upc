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
  final int duree; // en secondes

  const Note({
    this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
    required this.cheminAudio,
    required this.langue,
    required this.duree,
  });

  /// Creates a copy of the current Note with the given fields replaced with the new values.
  Note copy({
    int? id,
    String? titre,
    String? contenu,
    DateTime? dateCreation,
    String? cheminAudio,
    String? langue,
    int? duree,
  }) {
    return Note(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      cheminAudio: cheminAudio ?? this.cheminAudio,
      langue: langue ?? this.langue,
      duree: duree ?? this.duree,
    );
  }

  /// Converts a [Note] instance into a `Map` that can be stored in the database.
  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.titre: titre,
        NoteFields.contenu: contenu,
        NoteFields.dateCreation: dateCreation.toIso8601String(),
        NoteFields.cheminAudio: cheminAudio,
        NoteFields.langue: langue,
        NoteFields.duree: duree,
      };

  /// Creates a [Note] instance from a `Map` retrieved from the database.
  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        titre: json[NoteFields.titre] as String,
        contenu: json[NoteFields.contenu] as String,
        dateCreation: DateTime.parse(json[NoteFields.dateCreation] as String),
        cheminAudio: json[NoteFields.cheminAudio] as String,
        langue: json[NoteFields.langue] as String,
        duree: json[NoteFields.duree] as int,
      );
} 