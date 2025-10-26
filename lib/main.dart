import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bloc/bloc/note_bloc.dart';
import 'package:note_bloc/bloc/note_event.dart';
import 'package:note_bloc/repository/note_repository.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
// import 'edit_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(
      RepositoryProvider(
        create: (context) => NoteRepository(),
         child: BlocProvider(
           create: (context) => NoteBloc(
             context.read<NoteRepository>()
           )..add(NotesFetched()),
           child: MaterialApp(
             initialRoute: '/login',
             debugShowCheckedModeBanner: false,
             routes: {
               '/': (context) => const HomeScreen(),
               '/login': (context) => const LoginScreen(),
             },
           ),
         )
      )
  );
}