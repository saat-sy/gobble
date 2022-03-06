import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/multiplayer/multiplayer_bloc.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/puzzle_builder.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
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
          create: (context) => MultiplayerBloc()
            ..add(
              MultiplayerInitEvent(),
            ),
        )
      ],
      child: const PuzzleView(),
    );
  }
}

class PuzzleView extends StatefulWidget {
  const PuzzleView({Key? key}) : super(key: key);

  @override
  State<PuzzleView> createState() => _PuzzleViewState();
}

class _PuzzleViewState extends State<PuzzleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GobbleColors.background,
      appBar: getAppBar(),
      body: const PuzzleBuilder(),
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
              borderRadius: BorderRadius.all(
                Radius.circular(50),
              ),
            ),
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
