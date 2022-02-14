import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'mode_event.dart';
part 'mode_state.dart';

class ModeBloc extends Bloc<ModeEvent, ModeState> {
  ModeBloc() : super(ModeInitial()) {
    on<ChangeModeToSingle>(
      (event, emit) => emit(ModeSingle()),
    );
    on<ChangeModeToMulti>(
      (event, emit) => emit(ModeMulti()),
    );
  }
}
