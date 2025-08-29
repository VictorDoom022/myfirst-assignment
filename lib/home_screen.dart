import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/note.dart';

import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseFirestore database = FirebaseFirestore.instance;
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  bool isExpanded = true;
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
    QuerySnapshot<Map<String, dynamic>> result = await database.collection('notes')
      .doc(loggedInUser!.uid)
      .collection('userNotes')
      .get();

    List<Note> notes = result.docs.map((e) => Note.fromJson(e.data())).toList();
    setState(() {
      noteList = notes;
    });

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
                builder: (context) => const EditScreen(),
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
