import 'package:equatable/equatable.dart';
import 'package:gobble/models/position.dart';

enum PieceType { type1, type2 }

class Piece extends Equatable {
  final int value;
  final Position position;
  final bool isBlank;
  final PieceType pieceType;

  const Piece({
    this.value = -1,
    required this.position,
    this.isBlank = false,
    this.pieceType = PieceType.type1
  });

  @override
  List<Object?> get props => [value, position, isBlank];
}
