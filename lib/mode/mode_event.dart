part of 'mode_bloc.dart';

abstract class ModeEvent extends Equatable {
  const ModeEvent();

  @override
  List<Object> get props => [];
}

class ChangeModeToSingle extends ModeEvent {}

class ChangeModeToMulti extends ModeEvent {}