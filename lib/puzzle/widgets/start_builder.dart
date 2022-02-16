import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';

class StartBuilder extends StatefulWidget {
  final PuzzleType type;

  const StartBuilder({
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  _StartBuilderState createState() => _StartBuilderState();
}

class _StartBuilderState extends State<StartBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.type == PuzzleType.single
        ? PuzzleBoard(puzzle: context.read<PuzzleBloc>().state.puzzle)
        : PuzzleBoard(puzzle: context.read<PuzzleBloc>().state.puzzle);
  }
}
