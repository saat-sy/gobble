import 'package:flutter/material.dart';

class StartBuilder extends StatefulWidget {
  const StartBuilder({ Key? key }) : super(key: key);

  @override
  _StartBuilderState createState() => _StartBuilderState();
}

class _StartBuilderState extends State<StartBuilder> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
              width: MediaQuery.of(context).size.width * 0.85, height: MediaQuery.of(context).size.width * 0.85, color: Colors.red),
    );
  }
}