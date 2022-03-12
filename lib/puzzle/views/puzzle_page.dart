import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/multiplayer/multiplayer_bloc.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/puzzle_builder.dart';
import 'package:gobble/puzzle/widgets/settings_bottom_modal.dart';

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
      backgroundColor: Theme.of(context).backgroundColor,
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
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "Gobble",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              builder: (context) {
                return const SettingsBottomModal();
              },
            );
          },
          icon: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ],
    );
  }
}
