// THIS IS WHAT THE BLOC PASSES AND THIS WILL BE PASSED TO THE UI
part of 'puzzle_bloc.dart';

class PuzzleState extends Equatable {
  final Puzzle puzzle;
  final bool started;
  final PuzzleType puzzleType;
  final PieceType pieceType;
  final Piece lastMovedPiece;
  final bool first;
  final Player currentPlayer;
  final String code;
  final Player player;

  const PuzzleState({
    this.puzzle = const Puzzle(pieces: <Piece>[]),
    this.started = false,
    this.puzzleType = PuzzleType.offline,
    this.pieceType = PieceType.type1,
    this.lastMovedPiece = const Piece(
      position: Position(x: 0, y: 0),
    ),
    this.first = false,
    this.currentPlayer = Player.one,
    this.code = "",
    this.player = Player.one,
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    bool? started,
    PuzzleType? puzzleType,
    PieceType? pieceType,
    Piece? lastMovedPiece,
    bool? first,
    Player? currentPlayer,
    Player? player,
    String? code,
  }) {
    return PuzzleState(
        puzzle: puzzle ?? this.puzzle,
        started: started ?? this.started,
        puzzleType: puzzleType ?? this.puzzleType,
        pieceType: pieceType ?? this.pieceType,
        lastMovedPiece: lastMovedPiece ?? this.lastMovedPiece,
        first: first ?? this.first,
        currentPlayer: currentPlayer ?? this.currentPlayer,
        player: player ?? this.player,
        code: code ?? this.code);
  }

  @override
  List<Object> get props => [
        puzzle,
        started,
        puzzleType,
        pieceType,
        lastMovedPiece,
        first,
        currentPlayer,
        code,
        player
      ];
}
