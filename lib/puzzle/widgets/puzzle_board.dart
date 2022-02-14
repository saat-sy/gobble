import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/mode/mode_bloc.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle.dart';

class PuzzleBoard extends StatefulWidget {
  final double tabHeight;
  final double marginForTab;
  final Puzzle puzzle;

  const PuzzleBoard(
      {this.tabHeight = 0,
      this.marginForTab = 0,
      required this.puzzle,
      Key? key})
      : super(key: key);

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  // BOARD WIDTH
  late double sideOfBoard;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sideOfBoard = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Center(
          child: Container(
            margin:
                EdgeInsets.only(bottom: widget.tabHeight + widget.marginForTab),
            width: sideOfBoard,
            height: sideOfBoard,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              itemCount: 36,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) => getPiece(
                widget.puzzle.pieces[index],
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getBottomUI(context),
          ],
        ),
      ],
    );
  }

  Container getPiece(Piece piece) {
    Color pieceColor = GobbleColors.pieceType1;
    String value = "";
    Color valueColor = GobbleColors.valueType1;

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

    return Container(
      decoration: BoxDecoration(
        color: pieceColor,
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
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 30,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

  BlocBuilder getBottomUI(BuildContext context) {
    bool isSingle = true;

    final state = context.read<ModeBloc>().state;
    if (state is ModeMulti) isSingle = false;

    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) {
        if (state is PuzzleEmpty) {
          return _startButton(context, isSingle);
        } else if (state is PuzzleSingleStart || state is PuzzleMultiStart) {
          return _finishButton(context, isSingle);
        } else {
          return const Text('An error occured');
        }
      },
    );
  }

  Container _startButton(BuildContext context, bool isSingle) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.width * 0.1),
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            // START GAME PRESSED
            context
                .read<PuzzleBloc>()
                .add(isSingle ? LoadSinglePuzzle() : LoadMultiPuzzle());
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(37.5),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            primary: GobbleColors.black,
            onPrimary: GobbleColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text("START GAME"),
        ),
      ),
    );
  }

  Row _finishButton(BuildContext context, bool isSingle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            context
                .read<PuzzleBloc>()
                .add(isSingle ? LoadSinglePuzzle() : LoadMultiPuzzle());
          },
          icon: const Icon(
            CupertinoIcons.restart,
            color: GobbleColors.black,
          ),
        ),
        IconButton(
          onPressed: () {
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
