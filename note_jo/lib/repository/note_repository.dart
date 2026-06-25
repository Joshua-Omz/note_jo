import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:note_jo/components/models/note_model.dart';

class NoteRepository {
  // PRIVATE HELPER: locates (and creates) the notes/ folder on disk
  Future<Directory> _getNotesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }

  // SAVE: converts the note to JSON and writes it as <id>.json
  Future<void> saveNote(NoteModel note) async {
    final dir = await _getNotesDir();
    final file = File('${dir.path}/${note.id}.json');
    final jsonString = jsonEncode(note.toJson());
    await file.writeAsString(jsonString);
  }

  // LOAD ONE: reads <id>.json and reconstructs a NoteModel
  Future<NoteModel?> loadNote(String id) async {
    final dir = await _getNotesDir();
    final file = File('${dir.path}/$id.json');
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return NoteModel.fromJson(map);
  }

  // LOAD ALL: reads every .json file in the notes/ folder
  Future<List<NoteModel>> loadAllNotes() async {
    final dir = await _getNotesDir();
    // listSync() returns a List synchronously — safe to filter with .where()
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));
    final notes = <NoteModel>[];
    for (final file in files) {
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      notes.add(NoteModel.fromJson(map));
    }
    notes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return notes;
  }

  // DELETE: removes the .json file for a given id
  Future<void> deleteNote(String id) async {
    final dir = await _getNotesDir();
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // EXPORT: builds a plain-text string for sharing
  Future<String> exportNoteAsText(NoteModel note) async {
    return '${note.title}\n${note.category} · ${note.timeAgo}\n\n${note.brief}';
  }
}