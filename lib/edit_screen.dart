import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/note.dart';


enum EditScreenMode {
  VIEW,
  ADD,
  EDIT,
}

class EditScreen extends StatefulWidget {

  final EditScreenMode mode;
  final Note? note;

  const EditScreen({super.key, required this.mode, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {


  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController contentTextEditingController = TextEditingController();

  FirebaseFirestore database = FirebaseFirestore.instance;
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    switch(widget.mode) {
      case EditScreenMode.VIEW:
        titleTextEditingController.text = widget.note?.title ?? '';
        contentTextEditingController.text = widget.note?.content ?? '';
        break;
      case EditScreenMode.ADD:
        break;
      case EditScreenMode.EDIT:
        titleTextEditingController.text = widget.note?.title ?? '';
        contentTextEditingController.text = widget.note?.content ?? '';
        break;
    }
  }

  Future<void> saveNote(Note note) async {
    if(loggedInUser == null) return;
    try {
      DocumentReference<Map<String, dynamic>> result = await database.collection('notes')
        .doc(loggedInUser!.uid)
        .collection('userNotes')
        .add(note.toJson());

      Navigator.pop(context);
    } catch(e) {
      print(e);
      if(!kDebugMode) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  Future<void> updateNote(Note note) async {
    if (loggedInUser == null || note.id == null) return;

    try {
      await database
        .collection('notes')
        .doc(loggedInUser!.uid)
        .collection('userNotes')
        .doc(note.id)
        .update(note.toJson());

      Navigator.pop(context);
    } catch (e) {
      print(e);
      if(!kDebugMode) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(renderAppBarTitle()),
        actions: [
          widget.mode != EditScreenMode.VIEW ? IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () async {
              Note note = Note(
                id: widget.note?.id,
                title: titleTextEditingController.text,
                content: contentTextEditingController.text,
              );
              if(widget.note == null) {
                await saveNote(note);
              } else {
                await updateNote(note);
              }
            },
          ) : const SizedBox.shrink(),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextField(
                      controller: titleTextEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                      ),
                    ),
                    TextField(
                      minLines: 3,
                      maxLines: 10,
                      controller: contentTextEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Content',
                        border: InputBorder.none
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String renderAppBarTitle() {
    switch(widget.mode) {
      case EditScreenMode.VIEW:
        return 'View Note';
      case EditScreenMode.ADD:
        return 'Add new Note';
      case EditScreenMode.EDIT:
        return 'Edit Note';
    }
  }
}

