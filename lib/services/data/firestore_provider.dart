import 'package:animation_and_notes/services/data/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider implements Database {
  @override
  Future addNotes({required title, required notesAndContentMap}) async {
    return await FirebaseFirestore.instance
        .collection("notesRoom")
        .doc(title)
        .set(notesAndContentMap);
  }

  @override
  Future getNoteRooms() async {
    return await FirebaseFirestore.instance
        .collection('notesRoom')
        .orderBy(
          "time",
          descending: true,
        )
        .snapshots();
  }
}
