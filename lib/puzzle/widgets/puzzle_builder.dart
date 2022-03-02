import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/multiplayer/multiplayer_bloc.dart';
import 'package:gobble/puzzle/puzzle.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';

class PuzzleBuilder extends StatefulWidget {
  const PuzzleBuilder({Key? key}) : super(key: key);

  @override
  _PuzzleBuilderState createState() => _PuzzleBuilderState();
}

class _PuzzleBuilderState extends State<PuzzleBuilder>
    with TickerProviderStateMixin {
  // GAME SWITCHER
  late AnimationController _switcherController;
  late Animation<double> _switcherAnimation;

  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  // CODE SWITCHER
  late AnimationController _codeController;
  late Animation<double> _codeAnimation;

  @override
  void initState() {
    // FOR SWITCHER
    _switcherController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _switcherAnimation =
        Tween(begin: 1.0, end: 0.0).animate(_switcherController);

    // FOR BLUR
    _blurController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _blurAnimation = Tween(begin: 0.0, end: 3.5).animate(_blurController);

    // FOR CODE
    _codeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _codeAnimation = Tween(begin: 0.0, end: 1.0).animate(_codeController);

    super.initState();
  }

  @override
  void dispose() {
    _switcherController.dispose();
    _blurController.dispose();
    _codeController.dispose();
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
              opacity: _switcherAnimation,
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
            return Stack(
              children: [
                PuzzleBoard(
                  puzzle: state.puzzle,
                ),
                state.started ? Container() : _blurBuilder(),
                state.started
                    ? Container()
                    : FadeTransition(
                        opacity: _codeAnimation,
                        child: _onlineButtonsBuilder(),
                      ),
              ],
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
              crossFadeState: state.started
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOut,
            );
          },
        )
      ],
    );
  }

  BlocConsumer _onlineButtonsBuilder() {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: ((context, state) {
        if (state is InvalidCode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Invalid Code',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        } else if (state is LoadMultiBlocPuzzle) {
          context.read<PuzzleBloc>().add(
                LoadMultiPuzzle(
                  player: state.player,
                  puzzle: state.puzzle,
                  code: state.code,
                ),
              );
        }
      }),
      builder: (context, state) {
        CrossFadeState fadeState = CrossFadeState.showFirst;
        String code = "";

        if (state is InitMultiPlayerState) {
          if (state.isCodeAvailable) {
            fadeState = CrossFadeState.showSecond;
            code = state.code;
          } else {
            fadeState = CrossFadeState.showFirst;
          }
        } else if (state is OnCodeGenerated) {
          fadeState = CrossFadeState.showSecond;
          code = state.code;
        }

        return AnimatedCrossFade(
          firstChild: _startOnlineGame(),
          secondChild: _generateOnlineCode(code),
          duration: const Duration(milliseconds: 400),
          crossFadeState: fadeState,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
        );
      },
    );
  }

  SizedBox _startOnlineGame() {
    TextEditingController _textController = TextEditingController();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: ElevatedButton(
                onPressed: () {
                  context.read<MultiplayerBloc>().add(GenerateCode());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(32.5),
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
                child: const Text("Start a new game"),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12.0, bottom: 10),
              child: Text(
                "Do you have the game code?",
                style: TextStyle(
                  color: GobbleColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 40.5,
              child: TextFormField(
                controller: _textController,
                keyboardType: TextInputType.number,
                cursorColor: GobbleColors.black,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      context
                          .read<MultiplayerBloc>()
                          .add(JoinUsingCode(code: _textController.text));
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: GobbleColors.black,
                      size: 20,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFFb1b1b1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 10.0),
                  hintText: 'Enter the code',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        const BorderSide(color: GobbleColors.black, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        const BorderSide(color: GobbleColors.black, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _generateOnlineCode(String code) {
    TextEditingController _textController = TextEditingController();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              height: 40.5,
              child: Container(
                decoration: BoxDecoration(
                  color: GobbleColors.background,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: GobbleColors.black,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      color: GobbleColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 22.5,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                "Do you have the game code?",
                style: TextStyle(
                  color: GobbleColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      primary: GobbleColors.black,
                      onPrimary: GobbleColors.textLight,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomLeft: Radius.circular(50)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.share,
                          size: 18,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text("Share")
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      primary: GobbleColors.background,
                      onPrimary: GobbleColors.textDark,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.copy_rounded,
                          size: 18,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text("Copy")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 25),
              padding: const EdgeInsets.only(left: 12.0, bottom: 10),
              child: const Text(
                "Do you have the game code?",
                style: TextStyle(
                  color: GobbleColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 40.5,
              child: TextFormField(
                controller: _textController,
                keyboardType: TextInputType.number,
                cursorColor: GobbleColors.black,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      context
                          .read<MultiplayerBloc>()
                          .add(JoinUsingCode(code: _textController.text));
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: GobbleColors.black,
                      size: 20,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFFb1b1b1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 10.0),
                  hintText: 'Enter the code',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        const BorderSide(color: GobbleColors.black, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        const BorderSide(color: GobbleColors.black, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedBuilder _blurBuilder() {
    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, state) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  InkWell _switchButton(
      {required String title,
      required BuildContext context,
      required PuzzleType puzzleType}) {
    // CHECK IF THE TYPE IS ACTIVE
    bool active = context.read<PuzzleBloc>().state.puzzleType == puzzleType;

    if (active && puzzleType == PuzzleType.offline) {
      if (_codeAnimation.value != 0) {
        _codeController.reverse();
      }
      if (_blurAnimation.value != 0) {
        _blurController.reverse();
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        if (!active) {
          if (puzzleType == PuzzleType.online) {
            _blurController.forward();
            _codeController.forward();
          } else {
            _blurController.reverse();
            _codeController.reverse();
          }
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
            _switcherController.forward();
            // START GAME PRESSED
            context
                .read<PuzzleBloc>()
                // TODO: DO SOMETHING
                .add(LoadSinglePuzzle());
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
                // TODO: DO SOMETHING
                .add(LoadSinglePuzzle());
          },
          icon: const Icon(
            CupertinoIcons.restart,
            color: GobbleColors.black,
          ),
        ),
        IconButton(
          onPressed: () {
            _switcherController.reverse();
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
