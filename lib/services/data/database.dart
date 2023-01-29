abstract class Database {
  // create document for notes
  Future addNotes({required title, required notesAndContentMap});

  Future getNoteRooms();
}
