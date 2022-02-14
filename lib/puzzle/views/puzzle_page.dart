import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/mode/mode_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/default_builder.dart';
import 'package:gobble/puzzle/widgets/start_builder.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PuzzleBloc()
            ..add(
              LoadEmptyPuzzle(),
            ),
        ),
        BlocProvider(
          create: (context) => ModeBloc()
            ..add(
              ChangeModeToSingle(),
            ),
        )
      ],
      child: const PuzzleView(),
    );
  }
}

class PuzzleView extends StatelessWidget {
  const PuzzleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GobbleColors.background,
      appBar: getAppBar(),
      body: BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) {
          if (state is PuzzleEmpty) {
            return const DefaultBuilder();
          } else if (state is PuzzleSingleStart) {
            return StartBuilder(
              puzzle: state.puzzle,
              type: PuzzleType.single,
            );
          } else if (state is PuzzleMultiStart) {
            return StartBuilder(
              puzzle: state.puzzle,
              type: PuzzleType.multi,
            );
          } else {
            return const Text('Something went wrong.');
          }
        },
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
                color: GobbleColors.black,
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text("Gobble", style: TextStyle(color: GobbleColors.black))
        ],
      ),
      backgroundColor: GobbleColors.background,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.settings_outlined,
            color: GobbleColors.black,
          ),
        )
      ],
    );
  }
}
