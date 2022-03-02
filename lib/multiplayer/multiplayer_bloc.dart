import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:gobble/models/piece.dart';
import 'package:gobble/models/position.dart';
import 'package:gobble/models/puzzle.dart';
import 'package:gobble/puzzle/puzzle_functions.dart';
import 'package:gobble/strings/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'multiplayer_event.dart';
part 'multiplayer_state.dart';

class MultiplayerBloc extends Bloc<MultiplayerEvent, MultiplayerState> {
  MultiplayerBloc() : super(MultiplayerInitial()) {
    on<MultiplayerInitEvent>(_init);
    on<GenerateCode>(_generateCode);
    on<JoinUsingCode>(_joinUsingCode);
  }

  CollectionReference rooms = FirebaseFirestore.instance.collection("Rooms");

  void _init(MultiplayerInitEvent event, Emitter<MultiplayerState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(GobbleStrings.code);

    if (code != null) {
      emit(InitMultiPlayerState(
        isCodeAvailable: true,
        code: code,
      ));
    } else {
      emit(const InitMultiPlayerState(
        isCodeAvailable: false,
      ));
    }
  }

  void _generateCode(GenerateCode event, Emitter<MultiplayerState> emit) async {
    int min = 100000;
    int max = 999999;
    var codeInt, doc;

    // KEEP GENERATING NEW CODES UNTIL THE CODE DOES NOT EXIST
    do {
      codeInt = min + Random().nextInt(max - min);
      doc = await rooms.doc(codeInt.toString()).get();
    } while (doc.exists);

    String code = codeInt.toString();

    // STORE THE CODE IN SHAREDPREFS
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(GobbleStrings.code, code);

    // CREATE A NEW DOC WITH THAT ID
    await rooms.doc(code).set({
      'secondPlayer': false,
      'isMainPlayerActive': true,
    }).then((value) {
      emit(OnCodeGenerated(code: code));
    }).catchError(
      (error) => print("Failed to add user: $error"),
    );

    await emit.forEach(rooms.doc(code).snapshots(),
        onData: (DocumentSnapshot snapshot) {
      if (snapshot.get('secondPlayer')) {
        var puzMap = snapshot.get('puzzle');

        List<Piece> pieces = [];

        for (var piece in puzMap) {
          Position pos =
              Position(x: piece['position'][0], y: piece['position'][1]);
          Piece newPiece = Piece(
            pieceType:
                piece['pieceType'] == 1 ? PieceType.type1 : PieceType.type2,
            value: piece['value'],
            position: pos,
            direction: PuzzleFunctions.getDirectionOfPiece(pos.x, pos.y),
          );
          pieces.add(newPiece);
        }

        Puzzle newPuzzle = Puzzle(pieces: pieces);

        return LoadMultiBlocPuzzle(player: Player.one, puzzle: newPuzzle, code: code);
      } else {
        return OnCodeGenerated(code: code);
      }
    });
  }

  void _joinUsingCode(
      JoinUsingCode event, Emitter<MultiplayerState> emit) async {
    emit(LoadingState());

    var doc = await rooms.doc(event.code).get();

    if (!doc.exists) {
      emit(InvalidCode());
    } else {
      Puzzle puzzle = PuzzleFunctions.generatePuzzle();
      List<Map> mappedPuzzle = puzzle.convertToMap();
      await rooms.doc(event.code).update({
        'puzzle': mappedPuzzle,
        'secondPlayer': true,
        'lastUpdatedPiece': [-1, -1, -1, -1],
        'currentPlayer': 'one',
      }).then((value) {
        emit(
          LoadMultiBlocPuzzle(
            player: Player.two,
            puzzle: puzzle,
            code: event.code
          ),
        );
      });
    }
  }
}
