// THIS IS FOR INPUT FROM THE UI

part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class LoadEmptyPuzzle extends PuzzleEvent {}

class LoadSinglePuzzle extends PuzzleEvent {}

class LoadMultiPuzzle extends PuzzleEvent {}