part of 'multiplayer_bloc.dart';

abstract class MultiplayerEvent extends Equatable {
  const MultiplayerEvent();

  @override
  List<Object> get props => [];
}

// ON INIT
class MultiplayerInitEvent extends MultiplayerEvent {}

// CREATE A DOCUMENT AND RETURN A CODE
class GenerateCode extends MultiplayerEvent {}

// JOIN A DOCUMENT USING A CODE
class JoinUsingCode extends MultiplayerEvent {
  final String code;

  const JoinUsingCode({required this.code});

  @override
  List<Object> get props => [code];
}
