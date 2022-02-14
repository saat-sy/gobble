import 'package:flutter/material.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';

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
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.width * 0.85,
        color: Colors.red,
        child: Center(
          child: Text(
            widget.type == PuzzleType.single ? "Single" : "Multi",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
