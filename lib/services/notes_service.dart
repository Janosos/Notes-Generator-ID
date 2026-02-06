import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pdf_service.dart';
import '../models/note_model.dart';

class NotesService {
  static final NotesService _instance = NotesService._internal();

  factory NotesService() {
    return _instance;
  }

  NotesService._internal() {
    _loadNotes();
  }

  final ValueNotifier<List<Note>> notesNotifier = ValueNotifier<List<Note>>([]);

  List<Note> get notes => notesNotifier.value;

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes_data');

    if (notesJson != null) {
      final loadedNotes = notesJson
          .map((e) => Note.fromJson(jsonDecode(e)))
          .toList();
      notesNotifier.value = loadedNotes;
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notesNotifier.value
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList('notes_data', notesJson);
  }

  void addNote(Note note) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    currentNotes.insert(0, note); // Add to top
    notesNotifier.value = currentNotes;
    _saveNotes();
  }

  double get totalSales {
    return notes
        .where((n) => n.status != 'BORRADOR' && n.type == 'VENTA')
        .fold(0.0, (sum, note) => sum + note.totalAmount);
  }

  int get notesCount => notes.length;

  void deleteNote(Note note) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    currentNotes.remove(note);
    notesNotifier.value = currentNotes;
    _saveNotes();
  }

  void deleteNotes(List<Note> notesToDelete) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    for (var note in notesToDelete) {
      currentNotes.remove(note);
    }
    notesNotifier.value = currentNotes;
    _saveNotes();
  }

  void updateNote(Note oldNote, Note newNote) {
    final currentNotes = List<Note>.from(notesNotifier.value);
    final index = currentNotes.indexOf(oldNote);
    if (index != -1) {
      currentNotes[index] = newNote;
      notesNotifier.value = currentNotes;
      _saveNotes();
    }
  }

  // --- Folio Logic ---
  
  String getNextQuoteFolio() {
    return _getNextFolio('IDC', 'COTIZACION');
  }

  String getNextSaleFolio() {
    return _getNextFolio('IDN', 'VENTA');
  }

  String _getNextFolio(String prefix, String type) {
    final year = DateTime.now().year;
    // Filter notes of this type
    final typeNotes = notes.where((n) => n.type == type).toList();
    
    // Find max sequence for current year
    int maxSeq = 0;
    for (var note in typeNotes) {
      // Expected format: PRE-YYYY-NNN
      final parts = note.folio.split('-');
      if (parts.length == 3) {
         final noteYear = int.tryParse(parts[1]);
         final noteSeq = int.tryParse(parts[2]);
         
         if (noteYear == year && noteSeq != null) {
           if (noteSeq > maxSeq) maxSeq = noteSeq;
         }
      }
    }
    
    final nextSeq = maxSeq + 1;
    return '$prefix-$year-${nextSeq.toString().padLeft(3, '0')}';
  }

  Future<bool> exportAllNotesToZip(String languageCode) async {
    final completedNotes = notes.where((n) => n.status == 'COMPLETADA').toList();
    if (completedNotes.isEmpty) return false;

    final archive = Archive();

    for (var note in completedNotes) {
      // Generate PDF bytes
      final bytes = await PdfService().generateNotePdf(note, languageCode);
      // Clean filename
      final fileName = '${note.folio.replaceAll('#', '').replaceAll('-', '_')}_${note.clientName.replaceAll(' ', '_')}.pdf';
      archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
    }

    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    if (zipBytes != null) {
      // Windows / Desktop Support
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final dateStr = DateTime.now().toIso8601String().split('T').first;
        final fileName = XTypeGroup(label: 'ZIP', extensions: ['zip']);
        final result = await getSaveLocation(
          suggestedName: 'notas_backup_$dateStr.zip',
          acceptedTypeGroups: [fileName],
        );

        if (result != null) {
          final file = File(result.path);
          await file.writeAsBytes(zipBytes);
          return true; // Exported successfully
        }
        return false; // User cancelled
      } else {
        // Mobile Support
        final tempDir = await getTemporaryDirectory();
        final dateStr = DateTime.now().toIso8601String().split('T').first;
        final zipFile = File('${tempDir.path}/notas_backup_$dateStr.zip');
        await zipFile.writeAsBytes(zipBytes);

        // Share/Save
        final result = await Share.shareXFiles([XFile(zipFile.path)], text: 'Respaldo de Notas $dateStr');
        return result.status == ShareResultStatus.success;
      }
    }
    return false;
  }
}
