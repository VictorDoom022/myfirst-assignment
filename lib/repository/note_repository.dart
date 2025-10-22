import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_bloc/models/note.dart';

class NoteRepository {

  FirebaseFirestore database = FirebaseFirestore.instance;
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  Future<List<Note>> getAllNotes() async {
    QuerySnapshot<Map<String, dynamic>> result = await database.collection('notes')
        .doc(loggedInUser!.uid)
        .collection('userNotes')
        .get();

    List<Note> notes = result.docs.map((e) {
      Note note = Note.fromJson(e.data());
      note.id = e.id;
      return note;
    }).toList();

    return notes;
  }

  Future<Note?> addNote(Note note) async {
    if(loggedInUser == null) return null;
    DocumentReference<Map<String, dynamic>> result = await database.collection('notes')
      .doc(loggedInUser!.uid)
      .collection('userNotes')
      .add(note.toJson());

    return note;
  }

  Future<Note?> updateNote(Note note) async {
    if (loggedInUser == null || note.id == null) return null;

    await database
      .collection('notes')
      .doc(loggedInUser!.uid)
      .collection('userNotes')
      .doc(note.id)
      .update(note.toJson());

    return note;
  }

  Future<void> deleteNote(String id) async {
    await database.collection('notes')
      .doc(loggedInUser!.uid)
      .collection('userNotes')
      .doc(id)
      .delete();
  }
}