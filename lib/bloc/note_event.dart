import 'package:note_bloc/models/note.dart';

abstract class NoteEvent {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

// READ: Triggered on page load to fetch posts
class NotesFetched extends NoteEvent {}

// CREATE: Triggered when submitting a new Note
class NoteAdded extends NoteEvent {
  final Note note;

  const NoteAdded({ required this.note });

  @override
  List<Object> get props => [note];
}

// UPDATE: Triggered when saving changes to an existing Note
class NoteUpdated extends NoteEvent {
  final Note note;

  const NoteUpdated({ required this.note });

  @override
  List<Object> get props => [note];
}

// DELETE: Triggered when deleting a post
class NoteDeleted extends NoteEvent {
  final String id;

  const NoteDeleted(this.id);

  @override
  List<Object> get props => [id];
}