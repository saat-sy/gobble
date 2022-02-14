// THIS IS WHAT THE BLOC PASSES AND THIS WILL BE PASSED TO THE UI

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

class PuzzleSingleStart extends PuzzleState {
  final Puzzle puzzle;

  const PuzzleSingleStart({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}

class PuzzleMultiStart extends PuzzleState {
  final Puzzle puzzle;

  const PuzzleMultiStart({required this.puzzle});

  @override
  List<Object> get props => [puzzle];
}