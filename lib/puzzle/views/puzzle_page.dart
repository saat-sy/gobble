import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/puzzle/widgets/default_builder.dart';
import 'package:gobble/puzzle/widgets/start_builder.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({ Key? key }) : super(key: key);

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GobbleColors.background,
      appBar: getAppBar(),
      body: DefaultBuilder(),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: GobbleColors.black,
              borderRadius: BorderRadius.all(Radius.circular(50)) 
            ),
          ),
          const SizedBox(width: 10,),
          const Text(
            "Logo",
            style: TextStyle(
              color: GobbleColors.black
            )
          )
        ],
      ),
      backgroundColor: GobbleColors.background,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.settings_outlined,
            color: GobbleColors.black,
          ),
        )
      ],
    );
  }
}