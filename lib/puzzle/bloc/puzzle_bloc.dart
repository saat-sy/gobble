import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gobble/models/puzzle.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc() : super(PuzzleInitial()) {
    on<LoadEmptyPuzzle>(_onLoadEmpty);
    on<LoadSinglePlayerPuzzle>(_onLoadSingle);
    on<Load1v1Puzzle>(_onLoad1v1);
  }

  void _onLoadEmpty(LoadEmptyPuzzle event, Emitter<PuzzleState> emit) {
    emit(
      PuzzleEmpty(puzzle: event.puzzle)
    );
  }

  void _onLoadSingle(LoadSinglePlayerPuzzle event, Emitter<PuzzleState> emit) {
    emit(
      PuzzleStart(puzzle: event.puzzle)
    );
  }

  void _onLoad1v1(Load1v1Puzzle event, Emitter<PuzzleState> emit) {
    emit(
      PuzzleStart(puzzle: event.puzzle)
    );
  }
}
