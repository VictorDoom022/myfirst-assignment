import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:note_bloc/repository/note_repository.dart';

import 'edit_screen.dart';
import 'models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  User? loggedInUser = FirebaseAuth.instance.currentUser;

  bool isExpanded = true;
  String? focusedNoteID;
  List<Note> noteList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNotes();
    });
  }

  Future<void> loadNotes() async {
    if(loggedInUser == null) return;
    List<Note> notes = await NoteRepository().getAllNotes();

    setState(() {
      noteList = notes;
    });
  }

  Future<void> deleteNote(String id) async {
    if(loggedInUser == null) return;
    try {
      await NoteRepository().deleteNote(id);
      await loadNotes();

      if(!kDebugMode) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    } catch(e) {
      print(e);
      if(!kDebugMode) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                noteList.length.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                bool isLastItem = index == noteList.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: isExpanded ? 8 : 18,
                          horizontal: isExpanded ? 8 : 16
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditScreen(
                                note: noteList[index],
                                mode: EditScreenMode.VIEW,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          if(focusedNoteID == noteList[index].id) {
                            focusedNoteID = null;
                          } else {
                            focusedNoteID = noteList[index].id;
                          }
                          setState(() { });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    noteList[index].title ?? 'No title',
                                    style: const TextStyle(
                                        fontSize: 22
                                    ),
                                  ),
                                  isExpanded ? Text(
                                    noteList[index].content ?? 'No content',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ) : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                            focusedNoteID == noteList[index].id ? Row(
                              children: [
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditScreen(
                                          note: noteList[index],
                                          mode: EditScreenMode.EDIT,
                                        ),
                                      ),
                                    );
                                    await loadNotes();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () async {
                                    if(noteList[index].id == null) return;
                                    await deleteNote(noteList[index].id!);
                                  },
                                )
                              ],
                            ) : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    isLastItem ? const SizedBox.shrink() : const Divider(color: Colors.grey,),
                  ],
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: buildFloatingActionButtonSecion(),
    );
  }

  Widget buildFloatingActionButtonSecion() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Icon(
            isExpanded ? Icons.unfold_less : Icons.menu,
            color: Colors.white,
          ),
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
            shape: const MaterialStatePropertyAll(CircleBorder()),
            backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () async {
            await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditScreen(mode: EditScreenMode.ADD),
                )
            );
            await loadNotes();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
            shape: const MaterialStatePropertyAll(CircleBorder()),
            backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}