import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gobble/multiplayer/multiplayer_bloc.dart';
import 'package:gobble/puzzle/bloc/puzzle_bloc.dart';
import 'package:gobble/puzzle/widgets/puzzle_builder.dart';
import 'package:gobble/puzzle/widgets/settings_bottom_modal.dart';
import 'package:gobble/themes/app_themes.dart';

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
          SvgPicture.asset(
            Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).primaryColor ==
                        appThemeData[AppTheme.blackLight]?.primaryColor
                    ? "assets/icon/icon-light-black.svg"
                    : "assets/icon/icon-light-blue.svg"
                : Theme.of(context).primaryColor ==
                        appThemeData[AppTheme.blackDark]?.primaryColor
                    ? "assets/icon/icon-dark-black.svg"
                    : "assets/icon/icon-dark-blue.svg",
            height: 30,
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
