import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gobble/colors/colors.dart';

class WaitingToStartDialog extends StatelessWidget {
  const WaitingToStartDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitThreeBounce(
            color: GobbleColors.black,
            size: 35,
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Text(
              'Waiting for Player 1 to start',
              style: TextStyle(
                color: GobbleColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: const Text(
              'The game will begin automatically when Player 1 starts it',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GobbleColors.textDark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}