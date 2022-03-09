import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle.dart';

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

class _PuzzleBoardState extends State<PuzzleBoard> {
  // BOARD WIDTH
  double sideOfBoard = 0;
  double sideOfPiece = 0;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sideOfBoard = MediaQuery.of(context).size.width;

    sideOfPiece = ((sideOfBoard * 0.9) / 5.0) - (8);

    return Center(
      child: SizedBox(
        width: sideOfBoard,
        height: sideOfBoard,
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
    Color pieceColor = GobbleColors.pieceType1;
    String value = "";
    Color valueColor = GobbleColors.valueType1;

    Tween<double> _tween = Tween<double>(begin: 0, end: 1);

    if (!piece.isBlank) {
      // ASSIGN VAL TO THE ACTUAL VALUE
      value = piece.value.toString();

      // ASSIGN THE ACTUAL PIECE COLOR
      pieceColor = piece.pieceType == PieceType.type1
          ? GobbleColors.pieceType1
          : GobbleColors.pieceType2;

      // ASSIGN THE VALUE PIECE COLOR
      valueColor = piece.pieceType == PieceType.type1
          ? GobbleColors.valueType1
          : GobbleColors.valueType2;
    }

    Color shadowColor = Colors.black.withOpacity(0.2);

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
          color: GobbleColors.background,
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
          color: GobbleColors.background,
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
            milliseconds: context.read<PuzzleBloc>().state.first
                ? 350 + Random().nextInt(350)
                : 0),
        curve: Curves.easeInExpo,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
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
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                  color: valueColor, fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
        ),
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
