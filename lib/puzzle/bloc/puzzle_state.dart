// THIS IS WHAT THE BLOC PASSES AND THIS WILL BE PASSED TO THE UI
part of 'puzzle_bloc.dart';

class PuzzleState extends Equatable {
  final Puzzle puzzle;
  final bool started;
  final PuzzleType type;
  final Piece lastEditedPiece;

  const PuzzleState({
    this.puzzle = const Puzzle(pieces: <Piece>[]),
    this.started = false,
    this.type = PuzzleType.single,
    this.lastEditedPiece = const Piece(
      position: Position(x: 0, y: 0),
    ),
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    bool? started,
    PuzzleType? type,
    Piece? lastEditedPiece,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      started: started ?? this.started,
      type: type ?? this.type,
      lastEditedPiece: lastEditedPiece ?? this.lastEditedPiece,
    );
  }

  @override
  List<Object> get props => [
        puzzle,
        started,
        type,
        lastEditedPiece,
      ];
}
