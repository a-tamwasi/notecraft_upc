import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class to define constant names for database tables.
/// This prevents typos and centralizes table names.
class DBTables {
  static const String notes = 'notes';
  static const String astuces = 'astuces';
}

/// Helper class to define constant names for the fields in the 'notes' table.
class NoteFields {
  static const String id = 'id';
  static const String titre = 'titre';
  static const String contenu = 'contenu';
  static const String dateCreation = 'dateCreation';
  static const String cheminAudio = 'cheminAudio';
  static const String langue = 'langue';
}

/// Helper class to define constant names for the fields in the 'astuces' table.
class AstuceFields {
  static const String id = 'id';
  static const String titre = 'titre';
  static const String contenu = 'contenu';
  static const String imageUrl = 'imageUrl';
}

class DatabaseService {
  // Singleton pattern to ensure only one instance of the database service.
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  static Database? _database;
  static const int _dbVersion = 2; // INCREMENTED DB VERSION
  static const String _dbName = 'notecraft.db'; // The name of our database file.

  /// Getter for the database.
  /// If the database is not initialized, it will initialize it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initializes the database.
  /// This includes finding the path, opening the database, and setting up
  /// creation and upgrade logic.
  Future<Database> _initDB() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _dbName);
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de la DB: $e');
      // Rethrowing the error allows upper layers (e.g., the UI) to handle it.
      rethrow;
    }
  }

  /// Called when the database is created for the very first time.
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }
  
  /// Centralized method to create all tables.
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DBTables.notes}(
        ${NoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${NoteFields.titre} TEXT NOT NULL,
        ${NoteFields.contenu} TEXT NOT NULL,
        ${NoteFields.dateCreation} TEXT NOT NULL,
        ${NoteFields.cheminAudio} TEXT NOT NULL,
        ${NoteFields.langue} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DBTables.astuces}(
        ${AstuceFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AstuceFields.titre} TEXT NOT NULL,
        ${AstuceFields.contenu} TEXT NOT NULL,
        ${AstuceFields.imageUrl} TEXT NOT NULL
      )
    ''');
    
    // We can add user and history tables here later.
    // await db.execute(... create user table ...);
    // await db.execute(... create history table ...);
  }

  /// Called when the database needs to be upgraded.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Step 1: Rename old notes table to a temporary name
      await db.execute('ALTER TABLE ${DBTables.notes} RENAME TO notes_old');
      
      // Step 2: Create the new notes table with the correct schema
      await db.execute('''
        CREATE TABLE ${DBTables.notes}(
          ${NoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${NoteFields.titre} TEXT NOT NULL,
          ${NoteFields.contenu} TEXT NOT NULL,
          ${NoteFields.dateCreation} TEXT NOT NULL,
          ${NoteFields.cheminAudio} TEXT NOT NULL,
          ${NoteFields.langue} TEXT NOT NULL
        )
      ''');
      
      // Step 3: Copy data from the old table to the new one, providing default values for new columns
      await db.execute('''
        INSERT INTO ${DBTables.notes} (${NoteFields.id}, ${NoteFields.titre}, ${NoteFields.contenu}, ${NoteFields.dateCreation}, ${NoteFields.cheminAudio}, ${NoteFields.langue})
        SELECT ${NoteFields.id}, ${NoteFields.titre}, ${NoteFields.contenu}, ${NoteFields.dateCreation}, '', 'fr-FR' FROM notes_old
      ''');
      
      // Step 4: Drop the old table
      await db.execute('DROP TABLE notes_old');

      // Update for astuces table
      await db.execute('ALTER TABLE ${DBTables.astuces} RENAME TO astuces_old');
      await db.execute('''
        CREATE TABLE ${DBTables.astuces}(
          ${AstuceFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AstuceFields.titre} TEXT NOT NULL,
          ${AstuceFields.contenu} TEXT NOT NULL,
          ${AstuceFields.imageUrl} TEXT NOT NULL
        )
      ''');
       await db.execute('''
        INSERT INTO ${DBTables.astuces} (${AstuceFields.id}, ${AstuceFields.titre}, ${AstuceFields.contenu}, ${AstuceFields.imageUrl})
        SELECT ${AstuceFields.id}, ${AstuceFields.titre}, ${AstuceFields.contenu}, '' FROM astuces_old
      ''');
      await db.execute('DROP TABLE astuces_old');
    }
  }
} 