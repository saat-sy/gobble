import 'package:equatable/equatable.dart';
import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/position.dart';

enum PieceType { type1, type2 }

class Piece extends Equatable {
  final int value;
  final Position position;
  final bool isBlank;
  final PieceType pieceType;
  final MyDismissDirection direction;

  const Piece(
      {this.value = -1,
      this.direction = MyDismissDirection.none,
      required this.position,
      this.isBlank = false,
      this.pieceType = PieceType.type1});

  @override
  List<Object?> get props => [value, position, isBlank];

  Piece changeDirectionToNone() {
    return Piece(
      value: value,
      direction: MyDismissDirection.none,
      position: position,
      isBlank: isBlank,
      pieceType: pieceType
    );
  }

  Piece changeDirection(MyDismissDirection direction) {
    return Piece(
      value: value,
      direction: direction,
      position: position,
      isBlank: isBlank,
      pieceType: pieceType
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'position': [position.x, position.y],
      'pieceType': pieceType == PieceType.type1 ? 1 : 2
    };
  }
}
