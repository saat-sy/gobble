import 'package:flutter/material.dart';
import 'package:gobble/colors/colors.dart';

class OfflineWinnerDialog extends StatelessWidget {
  final VoidCallback onBackPress;
  final String playerWon;

  const OfflineWinnerDialog({
    required this.onBackPress,
    required this.playerWon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: const [
              _ClipPathForDialog(won: true),
              _ImageForDialog(won: true),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const _MainHeading(text: 'Congratulations!!'),
          const SizedBox(height: 12.5),
          _SubHeading(text: '$playerWon won the game'),
          const SizedBox(height: 12.5),
          _BackButton(onBackPress: onBackPress,),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class OnlineWinnerDialog extends StatelessWidget {
  final VoidCallback onBackPress;

  const OnlineWinnerDialog({
    required this.onBackPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: const [
              _ClipPathForDialog(won: true),
              _ImageForDialog(won: true),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const _MainHeading(text: 'Congratulations!!'),
          const SizedBox(height: 12.5),
          const _SubHeading(text: 'You won!'),
          const SizedBox(height: 12.5),
          _BackButton(onBackPress: onBackPress,),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class OnlineLoserDialog extends StatelessWidget {
  final VoidCallback onBackPress;

  const OnlineLoserDialog({
    required this.onBackPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: const [
              _ClipPathForDialog(won: false),
              _ImageForDialog(won: false),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const _MainHeading(text: 'Aww snap...'),
          const SizedBox(height: 12.5),
          const _SubHeading(text: 'Better luck next time'),
          const SizedBox(height: 12.5),
          _BackButton(onBackPress: onBackPress,),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    Key? key,
    required this.onBackPress,
  }) : super(key: key);

  final VoidCallback onBackPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onBackPress,
      style: ElevatedButton.styleFrom(
        primary: GobbleColors.black,
        onPrimary: GobbleColors.textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('Back'),
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class _MainHeading extends StatelessWidget {
  const _MainHeading({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ImageForDialog extends StatelessWidget {
  final bool won;
  const _ImageForDialog({
    Key? key,
    required this.won,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Image.asset(
          won ? 'assets/winner.png' : 'assets/loser.png',
          height: won ? 125 : 100,
        ),
      ),
    );
  }
}

class _ClipPathForDialog extends StatelessWidget {
  final bool won;
  const _ClipPathForDialog({
    Key? key,
    required this.won,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RoundClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: won ? const Color(0xFFC3F8DA) : const Color(0xFFF7746A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        height: 150,
      ),
    );
  }
}

class RoundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var pointStart = Offset(size.width / 2, size.height);
    var pointEnd = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
        pointStart.dx, pointStart.dy, pointEnd.dx, pointEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
