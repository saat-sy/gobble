import 'package:flutter/material.dart';

class StartOrNotDialog extends StatelessWidget {
  final VoidCallback yesPressed;
  final VoidCallback noPressed;

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
            child: Text(
              'Start the game',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 19),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            child: Text(
              'Player 2 has joined the game. Do you want to start it?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: noPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(37.5),
                    primary: Theme.of(context).primaryColorDark,
                    onPrimary: Theme.of(context).primaryColorLight,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(23),
                      ),
                    ),
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
                  onPressed: yesPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(37.5),
                    primary: Theme.of(context).cardColor,
                    // RETURNS A LIGHT COLOR WHEN IT'S DARK AND VICE VERSA
                    onPrimary: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight,
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
