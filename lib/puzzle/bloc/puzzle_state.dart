// THIS IS WHAT THE BLOC PASSES AND THIS WILL BE PASSED TO THE UI
part of 'puzzle_bloc.dart';

class PuzzleState extends Equatable {
  final Puzzle puzzle;
  final bool started;
  final PuzzleType puzzleType;
  final PieceType pieceType;
  final Piece lastMovedPiece;
  final bool first;

  const PuzzleState({
    this.puzzle = const Puzzle(pieces: <Piece>[]),
    this.started = false,
    this.puzzleType = PuzzleType.offline,
    this.pieceType = PieceType.type1,
    this.lastMovedPiece = const Piece(
      position: Position(x: 0, y: 0),
    ),
    this.first = false,
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    bool? started,
    PuzzleType? type,
    PieceType? pieceType,
    Piece? lastMovedPiece,
    bool? first,
  }) {
    return PuzzleState(
        puzzle: puzzle ?? this.puzzle,
        started: started ?? this.started,
        puzzleType: type ?? puzzleType,
        pieceType: pieceType ?? this.pieceType,
        lastMovedPiece: lastMovedPiece ?? this.lastMovedPiece,
        first: first ?? this.first);
  }

  @override
  List<Object> get props => [
        puzzle,
        started,
        puzzleType,
        pieceType,
        lastMovedPiece,
        first,
      ];
}
