import 'package:notecraft_upc/data/database/database_service.dart';
import 'package:notecraft_upc/models/note_model.dart';

/// Abstract definition for a repository that handles note-related data operations.
/// By coding to an interface, we can easily swap implementations (e.g., for testing).
abstract class NoteRepository {
  Future<Note> addNote(Note note);
  Future<Note?> getNoteById(int id);
  Future<List<Note>> getAllNotes();
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
}

/// Concrete implementation of [NoteRepository] using SQFlite.
class NoteRepositoryImpl implements NoteRepository {
  final DatabaseService _databaseService;

  NoteRepositoryImpl(this._databaseService);

  @override
  Future<Note> addNote(Note note) async {
    final db = await _databaseService.database;
    final id = await db.insert(DBTables.notes, note.toMap());
    return note.copyWith(id: id);
  }

  @override
  Future<int> deleteNote(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      DBTables.notes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DBTables.notes,
      orderBy: '${NoteFields.dateCreation} DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  @override
  Future<Note?> getNoteById(int id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DBTables.notes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> updateNote(Note note) async {
    final db = await _databaseService.database;
    return await db.update(
      DBTables.notes,
      note.toMap(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }
} 