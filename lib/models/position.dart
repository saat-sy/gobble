import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int x;
  final int y;

  const Position({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];

  int convertPositionToIndex() {
    return (((x - 1) * 5) + y) - 1;
  }
}
