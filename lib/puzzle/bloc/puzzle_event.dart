// THIS IS FOR INPUT FROM THE UI

part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class LoadEmptyPuzzle extends PuzzleEvent {}

class LoadSinglePuzzle extends PuzzleEvent {}

class LoadMultiPuzzle extends PuzzleEvent {
  final Player player;
  final Puzzle puzzle;
  final String code;

  const LoadMultiPuzzle({
    required this.player,
    required this.puzzle,
    required this.code,
  });

  @override
  List<Object> get props => [player, puzzle, code];
}

class ChangePuzzleType extends PuzzleEvent {
  final PuzzleType puzzleType;

  const ChangePuzzleType({
    required this.puzzleType,
  });

  @override
  List<Object> get props => [puzzleType];
}

class PieceMoved extends PuzzleEvent {
  final Piece fromPiece;
  final Piece toPiece;
  final Puzzle puzzle;
  final PuzzleType puzzleType;

  const PieceMoved({
    required this.fromPiece,
    required this.toPiece,
    required this.puzzle,
    required this.puzzleType,
  });

  @override
  List<Object> get props => [fromPiece, toPiece, puzzle, puzzleType];
}
