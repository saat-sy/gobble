import 'package:equatable/equatable.dart';
import 'package:gobble/models/position.dart';

class Piece extends Equatable {
  final int value;
  final Position position;
  final bool isBlank;

  const Piece({
    required this.value,
    required this.position,
    this.isBlank = false,
  });

  @override
  List<Object?> get props => [value, position, isBlank];
}