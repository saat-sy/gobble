import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc() : super(const PuzzleState()) {
    on<LoadEmptyPuzzle>(_onLoadEmpty);
    on<LoadSinglePuzzle>(_onLoadSingle);
    on<LoadMultiPuzzle>(_onLoadMulti);
    on<ChangePuzzleType>(_changePuzzleType);
    on<PieceMoved>(_pieceMoved);
  }

  void _changePuzzleType(ChangePuzzleType event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(type: event.puzzleType),
    );
  }

  void _onLoadEmpty(LoadEmptyPuzzle event, Emitter<PuzzleState> emit) {
    emit(
      PuzzleState(
        puzzle: _generateEmptyPuzzle(),
        started: false,
      ),
    );
  }

  void _onLoadSingle(LoadSinglePuzzle event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(
        puzzle: _makeOppositeTypeImmovable(_generatePuzzle(), first: true),
        started: true,
        first: true,
      ),
    );
  }

  void _onLoadMulti(LoadMultiPuzzle event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(
        puzzle: _makeOppositeTypeImmovable(_generatePuzzle(), first: true),
        started: true,
        first: true,
      ),
    );
  }

  void _pieceMoved(PieceMoved event, Emitter<PuzzleState> emit) {
    List<Piece> pieces = event.puzzle.pieces;

    late Piece newFromPiece;
    late Piece newToPiece;

    newFromPiece = Piece(
      isBlank: true,
      position: event.fromPiece.position,
      direction: MyDismissDirection.none,
    );

    if (event.toPiece.isBlank) {
      newToPiece = Piece(
          position: event.toPiece.position,
          value: event.fromPiece.value,
          pieceType: event.fromPiece.pieceType,
          direction: _getDirectionOfPiece(
              event.toPiece.position.x, event.toPiece.position.y));
    } else {
      newToPiece = Piece(
        position: event.toPiece.position,
        value: event.fromPiece.pieceType == event.toPiece.pieceType
            ? event.fromPiece.value + event.toPiece.value
            : event.fromPiece.value,
        pieceType: event.fromPiece.pieceType,
        direction: _getDirectionOfPiece(
            event.toPiece.position.x, event.toPiece.position.y),
      );
    }

    pieces[event.fromPiece.position.convertPositionToIndex()] = newFromPiece;
    pieces[event.toPiece.position.convertPositionToIndex()] = newToPiece;

    Puzzle newPuzzle = Puzzle(pieces: pieces);

    newPuzzle = _makeOppositeTypeImmovable(newPuzzle);

    emit(
      state.copyWith(
        puzzle: newPuzzle,
        pieceType: _getPieceType(state.pieceType),
        lastMovedPiece: newToPiece,
        first: false,
      ),
    );
  }

  Puzzle _makeOppositeTypeImmovable(Puzzle puzzle, {bool first = false}) {
    List<Piece> newPieces = <Piece>[];

    for (var piece in puzzle.pieces) {
      Piece newPiece;
      if (!first) {
        if (piece.pieceType == state.pieceType) {
          newPiece = piece.changeDirectionToNone();
        } else {
          newPiece = piece.changeDirection(
              _getDirectionOfPiece(piece.position.x, piece.position.y));
        }
      } else {
        if (piece.pieceType != state.pieceType) {
          newPiece = piece.changeDirectionToNone();
        } else {
          newPiece = piece.changeDirection(
              _getDirectionOfPiece(piece.position.x, piece.position.y));
        }
      }
      newPieces.add(newPiece);
    }

    return Puzzle(pieces: newPieces);
  }

  PieceType _getPieceType(PieceType pieceType) {
    return pieceType == PieceType.type1 ? PieceType.type2 : PieceType.type1;
  }

  Puzzle _generateEmptyPuzzle() {
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

  Puzzle _generatePuzzle() {
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
        MyDismissDirection direction = _getDirectionOfPiece(i, j);

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

  MyDismissDirection _getDirectionOfPiece(int x, int y) {
    // 11 12 13 14 15 16
    // 21 22 23 24 25 26
    // 31 32 33 34 35 36
    // 41 42 43 44 45 46
    // 51 52 53 54 55 56
    // 61 62 63 64 65 66

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
}
