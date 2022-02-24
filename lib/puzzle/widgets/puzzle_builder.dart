import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';

class PuzzleBuilder extends StatefulWidget {
  const PuzzleBuilder({Key? key}) : super(key: key);

  @override
  _PuzzleBuilderState createState() => _PuzzleBuilderState();
}

class _PuzzleBuilderState extends State<PuzzleBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _animation = Tween(begin: 1.0, end: 0.0).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // GAME MODE SWITCHER
        BlocBuilder<PuzzleBloc, PuzzleState>(
          buildWhen: (previous, current) =>
              (previous.puzzleType != current.puzzleType) ||
              (previous.started != current.started),
          builder: (context, state) {
            return FadeTransition(
              opacity: _animation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _switchButton(
                    title: '1v1 Offline',
                    context: context,
                    puzzleType: PuzzleType.offline,
                  ),
                  _switchButton(
                    title: 'Multiplayer',
                    context: context,
                    puzzleType: PuzzleType.online,
                  ),
                ],
              ),
            );
          },
        ),

        // GRIDVIEW
        BlocBuilder<PuzzleBloc, PuzzleState>(
          buildWhen: (previous, current) => current.started || previous.started,
          builder: (context, state) {
            return PuzzleBoard(
              puzzle: state.puzzle,
            );
          },
        ),

        // BOTTOM
        BlocBuilder<PuzzleBloc, PuzzleState>(
          buildWhen: (previous, current) =>
              (previous.puzzleType != current.puzzleType) ||
              (previous.started != current.started),
          builder: (context, state) {
            bool isOffline = state.puzzleType == PuzzleType.offline;
            return AnimatedCrossFade(
              firstChild: _startButton(context, isOffline),
              secondChild: _finishButton(context, isOffline),
              duration: const Duration(milliseconds: 400),
              crossFadeState: state.started ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOut,
            );
          },
        )
      ],
    );
  }

  InkWell _switchButton(
      {required String title,
      required BuildContext context,
      required PuzzleType puzzleType}) {
    // CHECK IF THE TYPE IS ACTIVE
    bool active = context.read<PuzzleBloc>().state.puzzleType == puzzleType;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        if (!active) {
          context
              .read<PuzzleBloc>()
              .add(ChangePuzzleType(puzzleType: puzzleType));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.35,
        height: 35,
        decoration: BoxDecoration(
          color: active ? GobbleColors.black : GobbleColors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: GobbleColors.black,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: active ? GobbleColors.textLight : GobbleColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Container _startButton(BuildContext context, bool isOffline) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
        // vertical: MediaQuery.of(context).size.width * 0.1,
      ),
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            _controller.forward();
            // START GAME PRESSED
            context
                .read<PuzzleBloc>()
                .add(isOffline ? LoadSinglePuzzle() : LoadMultiPuzzle());
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(37.5),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            primary: GobbleColors.black,
            onPrimary: GobbleColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text("Start"),
        ),
      ),
    );
  }

  Row _finishButton(BuildContext context, bool isOffline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            context
                .read<PuzzleBloc>()
                .add(isOffline ? LoadSinglePuzzle() : LoadMultiPuzzle());
          },
          icon: const Icon(
            CupertinoIcons.restart,
            color: GobbleColors.black,
          ),
        ),
        IconButton(
          onPressed: () {
            _controller.reverse();
            context.read<PuzzleBloc>().add(LoadEmptyPuzzle());
          },
          icon: const Icon(
            CupertinoIcons.check_mark,
            color: GobbleColors.black,
          ),
        ),
      ],
    );
  }
}
