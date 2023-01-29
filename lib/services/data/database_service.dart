import 'package:animation_and_notes/services/data/database.dart';
import 'package:animation_and_notes/services/data/firestore_provider.dart';

class DatabaseService implements Database {
  final Database provider;
  DatabaseService(this.provider);
  factory DatabaseService.firestore() => DatabaseService(FirestoreProvider());

  @override
  Future addNotes({required title, required notesAndContentMap}) =>
      provider.addNotes(title: title, notesAndContentMap: notesAndContentMap);

  @override
  Future getNoteRooms() => provider.getNoteRooms();
}
