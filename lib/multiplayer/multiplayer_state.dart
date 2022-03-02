part of 'multiplayer_bloc.dart';

abstract class MultiplayerState extends Equatable {
  const MultiplayerState();

  @override
  List<Object> get props => [];
}

class MultiplayerInitial extends MultiplayerState {}

class InitMultiPlayerState extends MultiplayerState {
  final String code;
  final bool isCodeAvailable;

  const InitMultiPlayerState({
    required this.isCodeAvailable,
    this.code = "",
  });

  @override
  List<Object> get props => [code, isCodeAvailable];
}

class OnCodeGenerated extends MultiplayerState {
  final String code;

  const OnCodeGenerated({required this.code});

  @override
  List<Object> get props => [code];
}

class OnPlayer2Joined extends MultiplayerState {}

class InvalidCode extends MultiplayerState {}

class Player1Offline extends MultiplayerState {}

class LoadingState extends MultiplayerState {}

class WaitingForSecondPlayer extends MultiplayerState {}

class LoadMultiBlocPuzzle extends MultiplayerState {
  final Player player;
  final Puzzle puzzle;
  final String code;

  const LoadMultiBlocPuzzle({
    required this.player,
    required this.puzzle,
    required this.code
  });

  @override
  List<Object> get props => [player, puzzle, code];
}
