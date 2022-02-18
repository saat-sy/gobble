// THIS IS WHAT THE BLOC PASSES AND THIS WILL BE PASSED TO THE UI
part of 'puzzle_bloc.dart';

class PuzzleState extends Equatable {
  final Puzzle puzzle;
  final bool started;
  final PuzzleType type;
  final PieceType pieceType;
  final Piece lastMovedPiece;

  const PuzzleState({
    this.puzzle = const Puzzle(pieces: <Piece>[]),
    this.started = false,
    this.type = PuzzleType.single,
    this.pieceType = PieceType.type1,
    this.lastMovedPiece = const Piece(position: Position(x: 0, y: 0))
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    bool? started,
    PuzzleType? type,
    PieceType? pieceType,
    Piece? lastMovedPiece,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      started: started ?? this.started,
      type: type ?? this.type,
      pieceType: pieceType ?? this.pieceType,
      lastMovedPiece: lastMovedPiece ?? this.lastMovedPiece
    );
  }

  @override
  List<Object> get props => [
        puzzle,
        started,
        type,
        pieceType,
        lastMovedPiece
      ];
}
