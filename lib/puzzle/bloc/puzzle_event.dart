// THIS IS FOR INPUT FROM THE UI

part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class LoadEmptyPuzzle extends PuzzleEvent {}

class LoadSinglePuzzle extends PuzzleEvent {}

class LoadMultiPuzzle extends PuzzleEvent {}

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
  List<Object> get props => [fromPiece, toPiece, puzzle];
}
