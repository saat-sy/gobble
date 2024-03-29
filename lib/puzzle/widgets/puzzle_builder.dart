import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/multiplayer/multiplayer_bloc.dart';
import 'package:gobble/puzzle/puzzle.dart';
import 'package:gobble/puzzle/puzzle_functions.dart';
import 'package:gobble/puzzle/widgets/completed_dialog.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';
import 'package:gobble/puzzle/widgets/restart_or_start.dart';
import 'package:gobble/puzzle/widgets/settings_bottom_modal.dart';
import 'package:gobble/puzzle/widgets/start_or_not.dart';
import 'package:gobble/puzzle/widgets/waiting_to_start.dart';
import 'package:gobble/themes/app_themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:share_plus/share_plus.dart';

class PuzzleBuilder extends StatefulWidget {
  const PuzzleBuilder({Key? key}) : super(key: key);

  @override
  _PuzzleBuilderState createState() => _PuzzleBuilderState();
}

class _PuzzleBuilderState extends State<PuzzleBuilder>
    with TickerProviderStateMixin {
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  // CODE SWITCHER
  late AnimationController _codeController;
  late Animation<double> _codeAnimation;

  final TextEditingController _textController = TextEditingController();
  final reg = RegExp(r'^[0-9]{6}$');

  @override
  void initState() {
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
    _blurController.dispose();
    _codeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  late double sideOfBoard;

  @override
  Widget build(BuildContext context) {
    sideOfBoard = MediaQuery.of(context).size.width;

    sideOfBoard =
        ResponsiveValue(context, defaultValue: sideOfBoard, valueWhen: [
              Condition.equals(
                name: MOBILE,
                value: sideOfBoard *
                    (puzzleConstants['mobile-board-width-perc'] ?? 1.0),
              ),
              Condition.equals(
                name: TABLET,
                value: sideOfBoard *
                    (puzzleConstants['tablet-board-width-perc'] ?? 0.7),
              ),
              Condition.equals(
                name: DESKTOP,
                value: sideOfBoard *
                    (puzzleConstants['desktop-board-width-perc'] ?? 0.5),
              ),
              Condition.equals(
                name: 'XL',
                value: sideOfBoard *
                    (puzzleConstants['xl-board-width-perc'] ?? 0.4),
              ),
            ]).value ??
            sideOfBoard;

    return BlocListener<PuzzleBloc, PuzzleState>(
      listenWhen: (previous, current) => current.completed || current.draw,
      listener: (context, state) {
        BuildContext buildContext = context;

        if (state.completed) {
          Player winner;
          if (state.noOfType1 == 0) {
            winner = Player.two;
          } else {
            winner = Player.one;
          }

          if (state.puzzleType == PuzzleType.offline) {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, _, __) => OfflineWinnerDialog(
                onBackPress: () {
                  Navigator.pop(context);
                  buildContext.read<PuzzleBloc>().add(LoadEmptyPuzzle());
                },
                playerWon: winner == Player.one ? 'Player 1' : 'Player 2',
              ),
            );
          } else {
            if (state.player == winner) {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => OnlineWinnerDialog(
                  onBackPress: () {
                    Navigator.pop(context);
                    buildContext.read<PuzzleBloc>().add(LoadEmptyPuzzle());
                  },
                ),
              );
            } else {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => OnlineLoserDialog(
                  onBackPress: () {
                    Navigator.pop(context);
                    buildContext.read<PuzzleBloc>().add(LoadEmptyPuzzle());
                  },
                ),
              );
            }
          }
        } else {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) => DrawDialog(
              onBackPress: () {
                Navigator.pop(context);
                buildContext.read<PuzzleBloc>().add(LoadEmptyPuzzle());
              },
            ),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // GAME MODE SWITCHER
          BlocBuilder<PuzzleBloc, PuzzleState>(
            buildWhen: (previous, current) =>
                (previous.puzzleType != current.puzzleType) ||
                (previous.started != current.started) ||
                (previous.currentPlayer != current.currentPlayer),
            builder: (context, state) {
              if (MediaQuery.of(context).size.width < 600) {
                return getSwitcherForMobile(state, context);
              } else {
                return getSwitcherForDesktop(state);
              }
            },
          ),

          // GRIDVIEW
          BlocBuilder<PuzzleBloc, PuzzleState>(
            buildWhen: (previous, current) =>
                current.started ||
                previous.started ||
                previous.puzzle.pieces.isEmpty,
            builder: (context, state) {
              return Stack(
                children: [
                  PuzzleBoard(
                    puzzle: state.puzzle,
                  ),
                  state.started ? Container() : Center(child: _blurBuilder()),
                  state.started
                      ? Container()
                      : Center(
                          child: FadeTransition(
                            opacity: _codeAnimation,
                            child: _onlineButtonsBuilder(),
                          ),
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
      ),
    );
  }

  Container getSwitcherForDesktop(PuzzleState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveValue(
              context,
              defaultValue: 50.0,
              valueWhen: const [
                Condition.equals(name: TABLET, value: 50.0),
                Condition.equals(name: DESKTOP, value: 75.0)
              ],
            ).value ??
            50.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO
          Row(
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
                height: 45,
              ),
              Text(
                "obble",
                style: GoogleFonts.rubik(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              )
            ],
          ),

          // SWITCHER
          Row(
            children: [
              _switcherButtonForDesktop(
                puzzleType: PuzzleType.offline,
                text: "1v1 Offline",
              ),
              SizedBox(
                width: ResponsiveValue(
                  context,
                  defaultValue: 5.0,
                  valueWhen: const [
                    Condition.equals(name: TABLET, value: 5.0),
                    Condition.largerThan(name: TABLET, value: 20.0)
                  ],
                ).value,
              ),
              _switcherButtonForDesktop(
                puzzleType: PuzzleType.online,
                text: "Multiplayer",
              ),
              SizedBox(
                width: ResponsiveValue(
                  context,
                  defaultValue: 5.0,
                  valueWhen: const [
                    Condition.equals(name: TABLET, value: 5.0),
                    Condition.largerThan(name: TABLET, value: 20.0)
                  ],
                ).value,
              ),
              // SETTINGS
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
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
          )
        ],
      ),
    );
  }

  TextButton _switcherButtonForDesktop({
    required PuzzleType puzzleType,
    required String text,
  }) {
    bool active = context.read<PuzzleBloc>().state.puzzleType == puzzleType;
    return TextButton(
      onPressed: () {
        if (!context.read<PuzzleBloc>().state.started) {
          if (puzzleType == PuzzleType.online) {
            _blurController.forward();
            _codeController.forward();
          } else {
            _blurController.reverse();
            _codeController.reverse();
          }
          context.read<PuzzleBloc>().add(
                ChangePuzzleType(
                  puzzleType: puzzleType,
                ),
              );
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
          primary: active
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColorLight.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: GoogleFonts.rubik(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          )),
    );
  }

  AnimatedCrossFade getSwitcherForMobile(
      PuzzleState state, BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          state.started ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: Row(
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
      secondChild: Row(
        mainAxisAlignment: state.puzzleType == PuzzleType.online
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: [
          // CURRENT PLAYER
          getCurrentPlayerWidget(state),
          // PLAYER
          state.puzzleType == PuzzleType.online
              ? getPlayerWidget(state)
              : Container()
        ],
      ),
    );
  }

  Row getPlayerWidget(PuzzleState state) {
    return Row(
      children: [
        const Text('You are '),
        Container(
          margin: const EdgeInsets.all(4),
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: state.player == Player.one
                ? Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).dialogBackgroundColor
                : Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row getCurrentPlayerWidget(PuzzleState state) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: state.currentPlayer == Player.one
                ? Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).dialogBackgroundColor
                : Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const Text('\'s turn')
      ],
    );
  }

  BlocConsumer _onlineButtonsBuilder() {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: ((context, state) {
        if (state is LoadMultiBlocPuzzle) {
          if (state.player == Player.one) {
            BuildContext buildContext = context;
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              pageBuilder: (context, __, ___) {
                return StartOrNotDialog(
                  yesPressed: () {
                    buildContext.read<PuzzleBloc>().add(
                          LoadMultiPuzzle(
                            player: state.player,
                            puzzle: state.puzzle,
                            code: state.code,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  noPressed: () {
                    buildContext
                        .read<MultiplayerBloc>()
                        .add(CancelInvite(code: state.code));
                    Navigator.pop(context);
                  },
                );
              },
            );
          } else {
            Navigator.pop(context);
            context.read<PuzzleBloc>().add(
                  LoadMultiPuzzle(
                    player: state.player,
                    puzzle: state.puzzle,
                    code: state.code,
                  ),
                );
          }
        } else if (state is WaitingForFirstPlayer) {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, __, ___) {
              return const WaitingToStartDialog();
            },
          );
        } else if (state is OnGameCancelled) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Player 1 Cancelled your request',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      }),
      buildWhen: (previous, newState) {
        if (newState is LoadingState ||
            newState is InvalidCode ||
            newState is WaitingForFirstPlayer ||
            newState is WaitingForSecondPlayer) {
          return false;
        } else {
          return true;
        }
      },
      builder: (context, state) {
        // INITIALIZE
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

        return Container(
          constraints: BoxConstraints(
            maxHeight: sideOfBoard,
            maxWidth: sideOfBoard,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: sideOfBoard *
                (ResponsiveValue(context, defaultValue: 0.15, valueWhen: [
                      const Condition.largerThan(name: MOBILE, value: 0.25)
                    ]).value ??
                    0.15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCrossFade(
                firstChild: _startOnlineGame(),
                secondChild: _generateOnlineCode(code),
                duration: const Duration(milliseconds: 400),
                crossFadeState: fadeState,
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeOut,
              ),
              joinCodeFormField(),
            ],
          ),
        );
      },
    );
  }

  Container _startOnlineGame() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: ElevatedButton(
        onPressed: () {
          context.read<MultiplayerBloc>().add(GenerateCode());
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(
              ResponsiveValue(context, defaultValue: 37.5, valueWhen: const [
                    Condition.largerThan(name: MOBILE, value: 42.5),
                    Condition.largerThan(name: TABLET, value: 47.5),
                    Condition.largerThan(name: DESKTOP, value: 47.5)
                  ]).value ??
                  37.5),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          primary: Theme.of(context).cardColor,
          onPrimary: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child:
            context.read<MultiplayerBloc>().state is LoadingGeneratedCodeState
                ? SpinKitThreeBounce(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight,
                    size: 20,
                  )
                : const Text("Start a new game"),
      ),
    );
  }

  Column _generateOnlineCode(String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          height: 40.5,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Theme.of(context).primaryColorLight,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: SelectableText(
                    code,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 22.5,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      context.read<MultiplayerBloc>().add(GenerateCode());
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 10),
          child: Text(
            "Share this code with the other player",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await Share.share(code);
                },
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  primary: Theme.of(context).primaryColorLight,
                  onPrimary: Theme.of(context).primaryColorDark,
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
            Expanded(
              // width: MediaQuery.of(context).size.width * 0.35,
              child: ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Copied!',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  primary: Theme.of(context).primaryColorDark,
                  onPrimary: Theme.of(context).primaryColorLight,
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
        const SizedBox(
          height: 25,
        )
      ],
    );
  }

  AnimatedBuilder _blurBuilder() {
    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, state) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: max(0.001, _blurAnimation.value),
              sigmaY: max(0.001, _blurAnimation.value),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: sideOfBoard,
                maxWidth: sideOfBoard,
              ),
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
          color: active ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.rubik(
              // CHANGE PRIMARYDARK AND LIGHT BASED ON BRIGHTNESS
              color: Theme.of(context).brightness == Brightness.light
                  ? active
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColorLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder _startButton(BuildContext context, bool isOffline) {
    return BlocBuilder<MultiplayerBloc, MultiplayerState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            // vertical: MediaQuery.of(context).size.width * 0.1,
          ),
          constraints: BoxConstraints(
            maxWidth:
                sideOfBoard - MediaQuery.of(context).size.width * 0.1, // MARGIN
          ),
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                // START GAME PRESSED
                if (isOffline) {
                  context.read<PuzzleBloc>().add(LoadSinglePuzzle());
                } else {
                  if (isValid(_textController.text) == null) {
                    context
                        .read<MultiplayerBloc>()
                        .add(JoinUsingCode(code: _textController.text));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(ResponsiveValue(context,
                        defaultValue: 37.5,
                        valueWhen: const [
                          Condition.largerThan(name: MOBILE, value: 42.5),
                          Condition.largerThan(name: TABLET, value: 47.5),
                          Condition.largerThan(name: DESKTOP, value: 47.5)
                        ]).value ??
                    37.5),
                textStyle: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                primary: Theme.of(context).cardColor,
                // RETURNS A LIGHT COLOR WHEN IT'S DARK AND VICE VERSA
                onPrimary: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: isOffline
                  ? const Text("Start")
                  : state is LoadingState
                      ? SpinKitThreeBounce(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context).primaryColorLight,
                          size: 20,
                        )
                      : const Text("Start"),
            ),
          ),
        );
      },
    );
  }

  Row _finishButton(BuildContext context, bool isOffline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            BuildContext buildContext = context;
            showGeneralDialog(
              context: context,
              pageBuilder: (context, __, ___) {
                return EndOrRestartDialog(
                  noPressed: () => Navigator.pop(context),
                  yesPressed: () {
                    buildContext.read<PuzzleBloc>().add(LoadSinglePuzzle());
                    Navigator.pop(context);
                  },
                  end: false,
                );
              },
            );
          },
          icon: Icon(
            CupertinoIcons.restart,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        IconButton(
          onPressed: () {
            BuildContext buildContext = context;
            showGeneralDialog(
              context: context,
              pageBuilder: (context, __, ___) {
                return EndOrRestartDialog(
                  noPressed: () => Navigator.pop(context),
                  yesPressed: () {
                    buildContext.read<PuzzleBloc>().add(LoadEmptyPuzzle());
                    Navigator.pop(context);
                  },
                  end: true,
                );
              },
            );
          },
          icon: Icon(
            CupertinoIcons.check_mark,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ],
    );
  }

  Column joinCodeFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 10),
          child: Text(
            "Do you have the game code?",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        BlocBuilder<MultiplayerBloc, MultiplayerState>(
          buildWhen: (previous, current) =>
              current is LoadingState || current is InvalidCode,
          builder: (context, state) {
            return TextFormField(
              controller: _textController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              cursorColor: Theme.of(context).primaryColorLight,
              validator: (_) {
                if (state is InvalidCode) {
                  return 'This code is invalid';
                }
                return isValid(_textController.text);
              },
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFFb1b1b1),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                hintText: 'Enter the code',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColorLight, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColorLight, width: 1.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color: Theme.of(context).errorColor, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color: Theme.of(context).errorColor, width: 1.0),
                ),
                errorStyle: TextStyle(color: Theme.of(context).errorColor),
              ),
            );
          },
        ),
      ],
    );
  }

  String? isValid(String value) {
    if (value.isEmpty) {
      return null;
    } else if (!reg.hasMatch(value)) {
      return 'Enter a valid code';
    }
    return null;
  }
}
