import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bloc/bloc/note_event.dart';
import 'package:note_bloc/bloc/note_state.dart';
import 'package:note_bloc/models/note.dart';
import 'package:note_bloc/repository/note_repository.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {

  final NoteRepository noteRepository;

  NoteBloc(this.noteRepository) : super(NoteInitial()) {
   on<NotesFetched>(_onFetchNotes);
   on<NoteAdded>(_onAddNote);
   on<NoteUpdated>(_onUpdateNote);
   on<NoteDeleted>(_onDeleteNote);
  }

  Future<void> _fetchAndEmit(Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      List<Note> notes = await noteRepository.getAllNotes();
      emit(NoteSuccess(notes));
    } catch(e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onFetchNotes(NotesFetched event, Emitter<NoteState> emit) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _onAddNote(NoteAdded event, Emitter<NoteState> emit) async {
    try {
      await noteRepository.addNote(event.note);
      await _fetchAndEmit(emit);
    } catch(e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(NoteUpdated event, Emitter<NoteState> emit) async {
    try {
      await noteRepository.updateNote(event.note);
      await _fetchAndEmit(emit);
    } catch(e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(NoteDeleted event, Emitter<NoteState> emit) async {
    try {
      await noteRepository.deleteNote(event.id);
      await _fetchAndEmit(emit);
    } catch(e) {
      emit(NoteError(e.toString()));
    }
  }

}