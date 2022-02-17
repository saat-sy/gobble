import 'package:equatable/equatable.dart';
import 'package:gobble/models/piece.dart';

enum PuzzleType {
  single,
  multi
}

class Puzzle extends Equatable {
  final List<Piece> pieces;

  const Puzzle({required this.pieces});

  @override
  List<Object?> get props => [pieces];
}
