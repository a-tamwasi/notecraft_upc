import 'package:flutter/material.dart';
import 'package:notecraft_upc/data/repositories/note_repository.dart';
import 'package:notecraft_upc/models/note_model.dart';

/// Enum to represent the state of data loading.
enum ViewState { Idle, Loading, Success, Error }

/// A provider class for managing the state of notes.
/// It uses a [NoteRepository] to interact with the data layer and notifies
/// listeners of any changes to the state.
class NoteProvider extends ChangeNotifier {
  final NoteRepository _noteRepository;

  NoteProvider(this._noteRepository) {
    // Automatically fetch notes when the provider is created.
    fetchNotes();
  }

  // Internal state
  ViewState _state = ViewState.Idle;
  List<Note> _notes = [];
  String _errorMessage = '';

  // Public getters for the state
  ViewState get state => _state;
  List<Note> get notes => _notes;
  String get errorMessage => _errorMessage;

  // Private setter for state to ensure notifyListeners is called
  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Fetches all notes from the repository and updates the state.
  Future<void> fetchNotes() async {
    _setState(ViewState.Loading);
    try {
      _notes = await _noteRepository.getAllNotes();
      _setState(ViewState.Success);
    } catch (e) {
      _errorMessage = 'Failed to fetch notes: $e';
      _setState(ViewState.Error);
    }
  }

  /// Adds a new note and refetches the list to update the UI.
  Future<void> addNote(Note note) async {
    try {
      await _noteRepository.addNote(note);
      await fetchNotes(); // Refresh the list after adding
    } catch (e) {
      // Handle potential errors, maybe set an error message
      debugPrint('Failed to add note: $e');
    }
  }

  /// Updates an existing note and refetches the list.
  Future<void> updateNote(Note note) async {
    try {
      await _noteRepository.updateNote(note);
      await fetchNotes(); // Refresh the list
    } catch (e) {
      debugPrint('Failed to update note: $e');
    }
  }

  /// Deletes a note by its ID and refetches the list.
  Future<void> deleteNote(int id) async {
    try {
      await _noteRepository.deleteNote(id);
      await fetchNotes(); // Refresh the list
    } catch (e) {
      debugPrint('Failed to delete note: $e');
    }
  }
} 