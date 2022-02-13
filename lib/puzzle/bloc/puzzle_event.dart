part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class LoadEmptyPuzzle extends PuzzleEvent {
  final Puzzle puzzle;

  const LoadEmptyPuzzle({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}

class LoadSinglePlayerPuzzle extends PuzzleEvent {
  final Puzzle puzzle;

  const LoadSinglePlayerPuzzle({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}

class Load1v1Puzzle extends PuzzleEvent {
  final Puzzle puzzle;

  const Load1v1Puzzle({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}
