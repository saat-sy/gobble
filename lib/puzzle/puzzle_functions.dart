import 'dart:math';

import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';

Map<String, double> puzzleConstants = {
  'mobile-board-width-perc': 1.0,
  'tablet-board-width-perc': 0.7,
  'desktop-board-width-perc': 0.50,
  'xl-board-width-perc': 0.35,
};

abstract class PuzzleFunctions {

  static Puzzle generatePuzzle() {
    List<Piece> listOfPieces = <Piece>[];
    Random random = Random();
    List<int> possibleDigits = <int>[2, 4, 8];

    // THE COUNTER THAT COUNTS TILL 18 POSITIONS
    int counter = 0;

    // CREATE A LIST OF 18 TYPE1's AND 18 TYPE2's
    List<PieceType> pieceTypes = <PieceType>[];
    for (int i = 0; i < 25; i++) {
      pieceTypes.add(i < 13 ? PieceType.type1 : PieceType.type2);
    }
    // AND SHUFFLE IT
    pieceTypes.shuffle();

    for (int i = 1; i <= 5; i++) {
      for (int j = 1; j <= 5; j++) {
        Position position = Position(x: i, y: j);

        int value = possibleDigits[random.nextInt(3)];
        PieceType pieceType = pieceTypes[counter];
        MyDismissDirection direction = getDirectionOfPiece(i, j);

        Piece piece = Piece(
          position: position,
          value: value,
          pieceType: pieceType,
          direction: direction,
        );

        listOfPieces.add(piece);

        counter++;
      }
    }

    return Puzzle(pieces: listOfPieces);
  }

  static MyDismissDirection getDirectionOfPiece(int x, int y) {
    // 11 12 13 14 15
    // 21 22 23 24 25
    // 31 32 33 34 35
    // 41 42 43 44 45
    // 51 52 53 54 55

    if (x == 1) {
      if (y != 5 && y != 1) {
        return MyDismissDirection.top;
      } else if (y == 5) {
        return MyDismissDirection.topRight;
      } else {
        return MyDismissDirection.topLeft;
      }
    }
    // BOTTOM
    if (x == 5) {
      if (y != 5 && y != 1) {
        return MyDismissDirection.bottom;
      } else if (y == 5) {
        return MyDismissDirection.bottomRight;
      } else {
        return MyDismissDirection.bottomLeft;
      }
    }
    // LEFT
    else if (y == 1) {
      return MyDismissDirection.left;
    }
    // RIGHT
    else if (y == 5) {
      return MyDismissDirection.right;
    }
    // ALL OTHER PIECES
    else {
      return MyDismissDirection.all;
    }
  }

  static Puzzle generateEmptyPuzzle() {
    List<Piece> listOfPieces = <Piece>[];

    for (int i = 1; i <= 5; i++) {
      for (int j = 1; j <= 5; j++) {
        Position position = Position(x: i, y: j);

        Piece piece = Piece(
          position: position,
          isBlank: true,
        );

        listOfPieces.add(piece);
      }
    }

    return Puzzle(pieces: listOfPieces);
  }
}