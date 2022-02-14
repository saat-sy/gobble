import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';

class StartBuilder extends StatefulWidget {
  final Puzzle puzzle;
  final PuzzleType type;

  const StartBuilder({
    required this.puzzle,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  _StartBuilderState createState() => _StartBuilderState();
}

class _StartBuilderState extends State<StartBuilder> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) {
        if (state is PuzzleSingleStart) {
          return PuzzleBoard(
            puzzle: state.puzzle,
          );
        } else if (state is PuzzleMultiStart) {
          return PuzzleBoard(
            puzzle: state.puzzle,
          );
        } else {
          return const Text('An error occured');
        }
      },
    );
  }
}
