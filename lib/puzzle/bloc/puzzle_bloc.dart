import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:gobble/dismissible/my_dismissible.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle_functions.dart';
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
      state.copyWith(puzzleType: event.puzzleType),
    );
  }

  void _onLoadEmpty(LoadEmptyPuzzle event, Emitter<PuzzleState> emit) {
    emit(
      PuzzleState(
        puzzle: PuzzleFunctions.generateEmptyPuzzle(),
        started: false,
        puzzleType: PuzzleType.offline,
      ),
    );
  }

  void _onLoadSingle(LoadSinglePuzzle event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(
        puzzle: _makePieceImmovable(PuzzleFunctions.generatePuzzle(),
            currentPlayer: Player.one, type: PuzzleType.offline),
        started: true,
        first: true,
        puzzleType: PuzzleType.offline,
        currentPlayer: Player.one,
      ),
    );
  }

  void _onLoadMulti(LoadMultiPuzzle event, Emitter<PuzzleState> emit) async {
    Puzzle puz = event.puzzle;

    if (event.player == Player.one) {
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(event.code)
          .update({'started': true});
    }

    await emit.forEach(
      FirebaseFirestore.instance
          .collection("Rooms")
          .doc(event.code)
          .snapshots(),
      onData: (DocumentSnapshot snapshot) {
        Player cPlayer =
            snapshot.get("currentPlayer") == "one" ? Player.one : Player.two;

        if (snapshot.get('lastUpdatedPiece')[0] == -1 ||
            snapshot.get('lastUpdatedPiece')[1] == -1) {
          return state.copyWith(
            puzzle: _makePieceImmovable(puz,
                player: event.player,
                currentPlayer: Player.one,
                type: PuzzleType.online),
            started: true,
            first: true,
            code: event.code,
            player: event.player,
            currentPlayer: Player.one,
            puzzleType: PuzzleType.online,
          );
        } else {
          List<Piece> pieces = event.puzzle.pieces;

          Position fromPosition = Position(
              x: snapshot.get('lastUpdatedPiece')[0],
              y: snapshot.get('lastUpdatedPiece')[1]);

          Position toPosition = Position(
              x: snapshot.get('lastUpdatedPiece')[2],
              y: snapshot.get('lastUpdatedPiece')[3]);

          Piece fromPiece = pieces[fromPosition.convertPositionToIndex()];

          Piece toPiece = pieces[toPosition.convertPositionToIndex()];

          late Piece newFromPiece;
          late Piece newToPiece;

          newFromPiece = Piece(
            isBlank: true,
            position: fromPiece.position,
            direction: MyDismissDirection.none,
          );

          if (toPiece.isBlank) {
            newToPiece = Piece(
                position: toPiece.position,
                value: fromPiece.value,
                pieceType: fromPiece.pieceType,
                direction: PuzzleFunctions.getDirectionOfPiece(
                    toPiece.position.x, toPiece.position.y));
          } else {
            newToPiece = Piece(
              position: toPiece.position,
              value: fromPiece.pieceType == toPiece.pieceType
                  ? fromPiece.value + toPiece.value
                  : fromPiece.value,
              pieceType: fromPiece.pieceType,
              direction: PuzzleFunctions.getDirectionOfPiece(
                  toPiece.position.x, toPiece.position.y),
            );
          }

          pieces[fromPiece.position.convertPositionToIndex()] = newFromPiece;
          pieces[toPiece.position.convertPositionToIndex()] = newToPiece;

          Puzzle newPuzzle = Puzzle(pieces: pieces);

          return state.copyWith(
            puzzle: _makePieceImmovable(
              newPuzzle,
              currentPlayer: cPlayer,
              player: state.player,
              type: PuzzleType.online,
            ),
            pieceType: _getPieceType(state.pieceType),
            lastMovedPiece: newToPiece,
            first: false,
            currentPlayer: cPlayer,
            draw: snapshot.get('draw'),
          );
        }
      },
    );
  }

  void _pieceMoved(PieceMoved event, Emitter<PuzzleState> emit) async {
    List<Piece> pieces = event.puzzle.pieces;

    late Piece newFromPiece;
    late Piece newToPiece;
    Player newCurrentPlayer = Player.one;

    if (state.puzzleType == PuzzleType.online) {
      Player currentOnlinePlayer = Player.one;
      // GET PLAYER FROM FIREBASE
      await FirebaseFirestore.instance
          .collection("Rooms")
          .doc(state.code)
          .get()
          .then((value) {
        currentOnlinePlayer =
            value.get("currentPlayer") == "one" ? Player.one : Player.two;
      });

      if (currentOnlinePlayer == Player.one) {
        newCurrentPlayer = Player.two;
      } else {
        newCurrentPlayer = Player.one;
      }
    }

    newFromPiece = Piece(
      isBlank: true,
      position: event.fromPiece.position,
      direction: MyDismissDirection.none,
    );

    double newNoOfType1 = state.noOfType1, newNoOfType2 = state.noOfType2;

    if (event.toPiece.isBlank) {
      newToPiece = Piece(
          position: event.toPiece.position,
          value: event.fromPiece.value,
          pieceType: event.fromPiece.pieceType,
          direction: PuzzleFunctions.getDirectionOfPiece(
              event.toPiece.position.x, event.toPiece.position.y));
    } else {
      if (event.toPiece.pieceType == PieceType.type1) {
        newNoOfType1 -= 1;
      } else {
        newNoOfType2 -= 1;
      }
      newToPiece = Piece(
        position: event.toPiece.position,
        value: event.fromPiece.pieceType == event.toPiece.pieceType
            ? event.fromPiece.value + event.toPiece.value
            : event.fromPiece.value,
        pieceType: event.fromPiece.pieceType,
        direction: PuzzleFunctions.getDirectionOfPiece(
            event.toPiece.position.x, event.toPiece.position.y),
      );
    }

    pieces[event.fromPiece.position.convertPositionToIndex()] = newFromPiece;
    pieces[event.toPiece.position.convertPositionToIndex()] = newToPiece;

    Puzzle newPuzzle = Puzzle(pieces: pieces);

    if (state.puzzleType == PuzzleType.offline) {
      Player currentPlayer = state.currentPlayer;
      if (currentPlayer == Player.one) {
        newCurrentPlayer = Player.two;
      } else {
        newCurrentPlayer = Player.one;
      }
      newPuzzle = _makePieceImmovable(newPuzzle,
          type: state.puzzleType, currentPlayer: newCurrentPlayer);
    } else {
      newPuzzle = _makePieceImmovable(newPuzzle,
          type: state.puzzleType,
          currentPlayer: newCurrentPlayer,
          player: state.player);
    }

    if (newNoOfType1 == 0 || newNoOfType2 == 0) {
      emit(
        state.copyWith(
          completed: true,
        ),
      );
    }

    emit(
      state.copyWith(
        puzzle: newPuzzle,
        pieceType: _getPieceType(state.pieceType),
        lastMovedPiece: newToPiece,
        first: false,
        currentPlayer: newCurrentPlayer,
        noOfType1: newNoOfType1,
        noOfType2: newNoOfType2,
      ),
    );

    List<int> values = [];
    for (Piece piece in newPuzzle.pieces) {
      if (!piece.isBlank) {
        values.add(piece.value);
      }
    }

    Map<int, int> count = {};
    for (var i in values) {
      count[i] = (count[i] ?? 0) + 1;
    }

    bool draw = true;

    count.forEach((key, value) {
      if (value != 1) {
        draw = false;
      }
    });

    if (draw) {
      emit(
        state.copyWith(draw: true),
      );
    }

    if (state.puzzleType == PuzzleType.online) {
      await FirebaseFirestore.instance
          .collection("Rooms")
          .doc(state.code)
          .update({
        'lastUpdatedPiece': [
          event.fromPiece.position.x,
          event.fromPiece.position.y,
          event.toPiece.position.x,
          event.toPiece.position.y,
        ],
        'currentPlayer': newCurrentPlayer == Player.one ? "one" : "two",
        'draw': draw,
      });
    }
  }

  Puzzle _makePieceImmovable(Puzzle puzzle,
      {Player player = Player.one,
      required Player currentPlayer,
      required PuzzleType type}) {
    List<Piece> newPieces = <Piece>[];

    for (var piece in puzzle.pieces) {
      Piece newPiece = const Piece(position: Position(x: -1, y: -1));

      if (type == PuzzleType.offline) {
        // IF PLAYER IS ONE
        if (currentPlayer == Player.one) {
          // CHANGE TYPE 2 TO NONE
          if (piece.pieceType == PieceType.type2) {
            newPiece = piece.changeDirectionToNone();
          } else {
            newPiece = piece.changeDirection(
                PuzzleFunctions.getDirectionOfPiece(
                    piece.position.x, piece.position.y));
          }
        } else {
          if (piece.pieceType == PieceType.type1) {
            newPiece = piece.changeDirectionToNone();
          } else {
            newPiece = piece.changeDirection(
                PuzzleFunctions.getDirectionOfPiece(
                    piece.position.x, piece.position.y));
          }
        }
      } else {
        if (currentPlayer == player) {
          // IF PLAYER IS ONE
          if (currentPlayer == Player.one) {
            // CHANGE TYPE 2 TO NONE
            if (piece.pieceType == PieceType.type2) {
              newPiece = piece.changeDirectionToNone();
            } else {
              newPiece = piece.changeDirection(
                  PuzzleFunctions.getDirectionOfPiece(
                      piece.position.x, piece.position.y));
            }
          } else {
            if (piece.pieceType == PieceType.type1) {
              newPiece = piece.changeDirectionToNone();
            } else {
              newPiece = piece.changeDirection(
                  PuzzleFunctions.getDirectionOfPiece(
                      piece.position.x, piece.position.y));
            }
          }
        } else {
          newPiece = piece.changeDirectionToNone();
        }
      }

      newPieces.add(newPiece);
    }

    return Puzzle(pieces: newPieces);
  }

  PieceType _getPieceType(PieceType pieceType) {
    return pieceType == PieceType.type1 ? PieceType.type2 : PieceType.type1;
  }
}
