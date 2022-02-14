import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc() : super(PuzzleInitial()) {
    on<LoadEmptyPuzzle>(_onLoadEmpty);
    on<LoadSinglePuzzle>(_onLoadSingle);
    on<LoadMultiPuzzle>(_onLoadMulti);
  }

  void _onLoadEmpty(LoadEmptyPuzzle event, Emitter<PuzzleState> emit) {
    emit(PuzzleEmpty());
  }

  void _onLoadSingle(LoadSinglePuzzle event, Emitter<PuzzleState> emit) {
    emit(PuzzleSingleStart(puzzle: _generatePuzzle()));
  }

  void _onLoadMulti(LoadMultiPuzzle event, Emitter<PuzzleState> emit) {
    emit(PuzzleMultiStart(puzzle: _generatePuzzle()));
  }

  Puzzle _generatePuzzle() {
    List<Piece> listOfPieces = <Piece>[];
    Random random = Random();
    List<int> possibleDigits = <int>[2, 4, 8, 16];

    // THE COUNTER THAT COUNTS TILL 18 POSITIONS
    int counter = 0;

    // CREATE A LIST OF 18 TYPE1's AND 18 TYPE2's
    List<PieceType> pieceTypes = <PieceType>[];
    for (int i = 0; i < 36; i++) {
      pieceTypes.add(i < 18 ? PieceType.type1 : PieceType.type2);
    }
    // AND SHUFFLE IT
    pieceTypes.shuffle();

    for (int i = 1; i <= 6; i++) {
      for (int j = 1; j <= 6; j++) {
        Position position = Position(x: i, y: j);

        int value = possibleDigits[random.nextInt(4)];
        PieceType pieceType = pieceTypes[counter];

        Piece piece = Piece(
          position: position,
          value: value,
          pieceType: pieceType,
        );

        listOfPieces.add(piece);

        counter++;
      }
    }

    return Puzzle(pieces: listOfPieces);
  }
}
