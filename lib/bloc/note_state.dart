import 'package:note_bloc/models/note.dart';

abstract class NoteState {
  const NoteState();

  @override
  List<Object?> get props => [];
}

// Initial: The starting state.
class NoteInitial extends NoteState {}

// Loading: Show a spinner, e.g., during API calls.
class NoteLoading extends NoteState {}

class NoteSuccess extends NoteState {
  final List<Note> notes;
  final String? message;

  const NoteSuccess(this.notes, { this.message });

  @override
  List<Object?> get props => [notes, message];
}

class NoteError extends NoteState {
  final String message;
  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}
