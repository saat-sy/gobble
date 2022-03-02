import 'package:equatable/equatable.dart';
import 'package:gobble/models/piece.dart';

enum PuzzleType { offline, online }

enum Player { one, two }

class Puzzle extends Equatable {
  final List<Piece> pieces;

  const Puzzle({required this.pieces});

  @override
  List<Object?> get props => [pieces];

  List<Map> convertToMap() {
    List<Map> mappedPieces = [];
    for (Piece piece in pieces) {
      Map pieceMap = piece.toMap();
      mappedPieces.add(pieceMap);
    }
    return mappedPieces;
  }
}
