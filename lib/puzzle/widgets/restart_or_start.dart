import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EndOrRestartDialog extends StatelessWidget {
  final VoidCallback yesPressed;
  final VoidCallback noPressed;
  final bool end;
  final bool askOtherPlayer;

  const EndOrRestartDialog({
    Key? key,
    required this.noPressed,
    required this.yesPressed,
    required this.end,
    this.askOtherPlayer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String mainHeader = "", subHeader = "";

    if (end) {
      mainHeader = "End the game";
    } else {
      mainHeader = "Reset the game";
    }

    if (!askOtherPlayer) {
      if (end) {
        subHeader = "Do you want to end this game?";
      } else {
        subHeader = "Do you want to reset this game?";
      }
    } else {
      if (end) {
        subHeader =
            "The other player wants to end the game. Do you want to end it?";
      } else {
        subHeader =
            "The other player wants to reset the game. Do you want to reset it?";
      }
    }

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
              mainHeader,
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
              subHeader,
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
                    textStyle: TextStyle(fontFamily: GoogleFonts.rubik().fontFamily),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(23),
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Center(
                    child: Text(
                      'No',
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
                    textStyle: TextStyle(fontFamily: GoogleFonts.rubik().fontFamily),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(23),
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Center(
                    child: Text(
                      'Yes',
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
