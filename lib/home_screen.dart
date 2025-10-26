import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bloc/bloc/note_bloc.dart';
import 'package:note_bloc/bloc/note_event.dart';
import 'package:note_bloc/bloc/note_state.dart';
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

  @override
  void initState() {
    super.initState();
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
              child: BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  String displayLabel = '';
                  if(state is NoteSuccess) {
                    displayLabel = state.notes.length.toString();
                  }
                  return Text(
                    displayLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  );
                }
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocConsumer<NoteBloc, NoteState>(
              listener: (context, state) {
                if(state is NoteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An Error Occurred')),
                  );
                }

                if(state is NoteSuccess && state.message != null) {
                  ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                    SnackBar(content: Text(state.message ?? 'Unknown Message')),
                  );
                }
              },
              builder: (context, state) {
                if(state is NoteInitial) {
                  return const Center(
                    child: Text('Initializing...'),
                  );
                }

                if(state is NoteLoading) {
                  return const Center(
                    child: Text('Loading...'),
                  );
                }

                if(state is NoteError) {
                  return Center(
                    child: Text('Failed to fetch notes: ${state.message}'),
                  );
                }

                if(state is NoteSuccess) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      bool isLastItem = index == state.notes.length - 1;
                      Note note = state.notes[index];

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
                                      note: note,
                                      mode: EditScreenMode.VIEW,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                if(focusedNoteID == note.id) {
                                  focusedNoteID = null;
                                } else {
                                  focusedNoteID = note.id;
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
                                          note.title ?? 'No title',
                                          style: const TextStyle(
                                              fontSize: 22
                                          ),
                                        ),
                                        isExpanded ? Text(
                                          note.content ?? 'No content',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ) : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  focusedNoteID == note.id ? Row(
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
                                                note: note,
                                                mode: EditScreenMode.EDIT,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () async {
                                          if(note.id == null) return;
                                          context.read<NoteBloc>().add(
                                            NoteDeleted(note.id!)
                                          );
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
                  );
                }

                return const Center(
                  child: Text('Unknown State'),
                );
              },
            ),
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