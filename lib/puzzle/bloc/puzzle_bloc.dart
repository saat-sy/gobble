import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc() : super(PuzzleInitial()) {
    on<PuzzleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
