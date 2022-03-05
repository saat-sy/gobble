import 'package:flutter/material.dart';
import 'package:gobble/colors/colors.dart';

class StartOrNotDialog extends StatelessWidget {
  final Function yesPressed;
  final Function noPressed;

  const StartOrNotDialog({
    Key? key,
    required this.noPressed,
    required this.yesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Start the game',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: GobbleColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 19),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            child: const Text(
              'Player 2 has joined the game. Do you want to start it?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GobbleColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => noPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(37.5),
                    primary: GobbleColors.background,
                    onPrimary: GobbleColors.textDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(23),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        )),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => yesPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(37.5),
                    primary: GobbleColors.black,
                    onPrimary: GobbleColors.textLight,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(23),
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Center(
                    child: Text(
                      'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
