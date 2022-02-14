part of 'mode_bloc.dart';

abstract class ModeState extends Equatable {
  const ModeState();
  
  @override
  List<Object> get props => [];
}

class ModeInitial extends ModeState {}

class ModeSingle extends ModeState {}

class ModeMulti extends ModeState {}