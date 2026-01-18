import 'package:flutter/foundation.dart';
import '../models/note_model.dart';

class NotesService {
  static final NotesService _instance = NotesService._internal();

  factory NotesService() {
    return _instance;
  }

  NotesService._internal();

  final ValueNotifier<List<Note>> notesNotifier = ValueNotifier<List<Note>>([]);

  List<Note> get notes => notesNotifier.value;

  void addNote(Note note) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    currentNotes.insert(0, note); // Add to top
    notesNotifier.value = currentNotes;
  }

  double get totalSales {
    return notes.where((n) => n.status != 'BORRADOR').fold(0.0, (sum, note) => sum + note.totalAmount);
  }

  int get notesCount => notes.length;

  void deleteNote(Note note) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    currentNotes.remove(note);
    notesNotifier.value = currentNotes;
  }

  void deleteNotes(List<Note> notesToDelete) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    for (var note in notesToDelete) {
      currentNotes.remove(note);
    }
    notesNotifier.value = currentNotes;
  }

  void updateNote(Note oldNote, Note newNote) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    final index = currentNotes.indexOf(oldNote);
    if (index != -1) {
      currentNotes[index] = newNote;
      notesNotifier.value = currentNotes;
    }
  }
}
