import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle.dart';
import 'package:gobble/puzzle/puzzle_functions.dart';
import 'package:responsive_framework/responsive_value.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class PuzzleBoard extends StatefulWidget {
  final double tabHeight;
  final double marginForTab;
  final Puzzle puzzle;

  const PuzzleBoard({
    this.tabHeight = 0,
    this.marginForTab = 0,
    required this.puzzle,
    Key? key,
  }) : super(key: key);

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with SingleTickerProviderStateMixin {
  // BOARD WIDTH
  double sideOfBoard = 0;
  double sideOfPiece = 0;

  late AnimationController _lastMovedController;
  late Animation _lastMovedAnimation;

  late Piece selectedPiece;
  bool selected = false;

  String data = "";

  final directionToNum = {
    MyDismissDirection.up: const Position(x: -1, y: 0),
    MyDismissDirection.down: const Position(x: 1, y: 0),
    MyDismissDirection.startToEnd: const Position(x: 0, y: 1),
    MyDismissDirection.endToStart: const Position(x: 0, y: -1),
  };

  @override
  void initState() {
    _lastMovedController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    super.initState();
  }

  @override
  void dispose() {
    _lastMovedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sideOfBoard = MediaQuery.of(context).size.width;

    sideOfPiece = ((sideOfBoard * 0.9) / 5.0) - (8);

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

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: sideOfBoard,
          maxWidth: sideOfBoard,
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          itemCount: context.read<PuzzleBloc>().state.puzzle.pieces.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemBuilder: (context, index) => getPiece(
            context.read<PuzzleBloc>().state.puzzle.pieces[index],
          ),
        ),
      ),
    );
  }

  MyDismissible getPiece(Piece piece) {
    Color pieceColor = Theme.of(context).dialogBackgroundColor;
    String value = "";
    Color valueColor = Theme.of(context).primaryColorDark;

    Tween<double> _tween = Tween<double>(begin: 0, end: 1);

    PuzzleState state = context.read<PuzzleBloc>().state;

    if (!piece.isBlank) {
      // ASSIGN VAL TO THE ACTUAL VALUE
      value = piece.value.toString();

      if (Theme.of(context).brightness == Brightness.light) {
        // ASSIGN THE ACTUAL PIECE COLOR
        pieceColor = piece.pieceType == PieceType.type1
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColorLight;

        // ASSIGN THE VALUE PIECE COLOR
        valueColor = piece.pieceType == PieceType.type1
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark;
      } else {
        // ASSIGN THE ACTUAL PIECE COLOR
        pieceColor = piece.pieceType == PieceType.type1
            ? Theme.of(context).dialogBackgroundColor
            : Theme.of(context).primaryColorLight;

        // ASSIGN THE VALUE PIECE COLOR
        valueColor = piece.pieceType == PieceType.type1
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark;
      }
    }

    Color shadowColor = Colors.black.withOpacity(0.2);

    if (state.puzzleType == PuzzleType.online &&
        piece == state.lastMovedPiece &&
        state.currentPlayer == state.player) {
      _lastMovedAnimation = ColorTween(
        begin: Theme.of(context).dividerColor,
        end: pieceColor,
      ).animate(_lastMovedController);

      _lastMovedController.reset();
      _lastMovedController.forward();
    }

    return MyDismissible(
      direction: piece.direction,
      confirmDismiss: (direction) => _checkDismissible(direction, piece),
      onDismissed: (direction) {
        _movePiece(piece, direction);
      },
      resizeDuration: null,
      key: UniqueKey(),
      secondaryBackground: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: const EdgeInsets.all(4),
        height: sideOfPiece,
        width: sideOfPiece,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
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
      background: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: const EdgeInsets.all(4),
        height: sideOfPiece,
        width: sideOfPiece,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
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
      child: TweenAnimationBuilder<double>(
        tween: _tween,
        duration: Duration(
            milliseconds: state.first ? 350 + Random().nextInt(350) : 0),
        curve: Curves.easeInExpo,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AnimatedBuilder(
            animation: _lastMovedController,
            builder: (context, _) {
              return InkWell(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  height: sideOfPiece,
                  width: sideOfPiece,
                  decoration: BoxDecoration(
                    color: pieceColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    // ONLY WHEN IT IS ONLINE AND PIECE IS LASTMOVEDPIECE
                    border: state.puzzleType == PuzzleType.online &&
                            piece == state.lastMovedPiece &&
                            state.currentPlayer == state.player
                        ? Border.all(color: _lastMovedAnimation.value, width: 2.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: ResponsiveValue(
                          context,
                          defaultValue: 30.0,
                          valueWhen: const [
                            Condition.equals(name: MOBILE, value: 30.0),
                            Condition.equals(name: TABLET, value: 32.5),
                            Condition.equals(name: DESKTOP, value: 34.0),
                            Condition.equals(name: 'XL', value: 36.0),
                          ]
                        ).value,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  bool _checkDismissible(MyDismissDirection direction, Piece piece) {
    Piece targetPiece = _getTargetPiece(piece, direction);

    if (targetPiece.value == piece.value) {
      // _movePiece(piece, direction);
      return true;
    } else if (targetPiece.isBlank) {
      // _movePiece(piece, direction);
      return true;
    }
    return false;
  }

  void _movePiece(Piece piece, MyDismissDirection direction) {
    BlocProvider.of<PuzzleBloc>(context).add(
      PieceMoved(
        fromPiece: piece,
        toPiece: _getTargetPiece(piece, direction),
        puzzle: context.read<PuzzleBloc>().state.puzzle,
        puzzleType: context.read<PuzzleBloc>().state.puzzleType,
      ),
    );
  }

  Piece _getTargetPiece(Piece piece, MyDismissDirection direction) {
    Position deltaPosition = const Position(x: 0, y: 0);
    Position piecePos = piece.position;

    for (final entry in directionToNum.entries) {
      if (direction == entry.key) {
        deltaPosition = entry.value;
      }
    }

    Position newPosition = Position(
        x: piecePos.x + deltaPosition.x, y: piecePos.y + deltaPosition.y);

    int index = newPosition.convertPositionToIndex();

    Piece targetPiece = context.read<PuzzleBloc>().state.puzzle.pieces[index];
    return targetPiece;
  }
}
