part of 'puzzle_bloc.dart';

abstract class PuzzleState extends Equatable {
  const PuzzleState();

  @override
  List<Object> get props => [];
}

class PuzzleInitial extends PuzzleState {}

class PuzzleEmpty extends PuzzleState {
  final Puzzle puzzle;

  const PuzzleEmpty({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}

class PuzzleStart extends PuzzleState {
  final Puzzle puzzle;

  const PuzzleStart({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}