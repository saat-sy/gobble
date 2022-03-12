import 'package:flutter/material.dart';

enum AppTheme {
  blackLight,
  blackDark,
  blueLight,
  blueDark,
}

enum ThemeInterface {
  light,
  dark
}

enum ThemeColor {
  black,
  blue,
}

final appThemeData = {
  AppTheme.blackLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF353535), // USED IN LOGIC
    primaryColorLight: const Color(0xFF353535), // LIGHT = (DARK IN LIGHTMODE) AND (LIGHT IN DARKMODE)
    primaryColorDark: const Color(0xFFFFFFFF),
    backgroundColor: const Color(0xFFFFFFFF),
    dialogBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFF353535),
    errorColor: const Color(0xFFB00020),
  ),
  AppTheme.blackDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF353535),
    primaryColorLight: const Color.fromARGB(255, 240, 240, 240),
    primaryColorDark: const Color(0xFF353535),
    backgroundColor: const Color.fromARGB(255, 26, 26, 26),
    dialogBackgroundColor: const Color.fromARGB(255, 47, 47, 47),
    cardColor: const Color.fromARGB(255, 66, 66, 66),
    errorColor: const Color(0xFFCF6679),
  ),
  AppTheme.blueLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 0, 67, 119),
    primaryColorLight: const Color.fromARGB(255, 0, 67, 119),
    primaryColorDark: const Color(0xFFFFFFFF),
    backgroundColor: const Color(0xFFFFFFFF),
    dialogBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color.fromARGB(255, 0, 67, 119),
    errorColor: const Color(0xFFB00020),
    highlightColor: const Color(0xFFBED0DE),
  ),
  AppTheme.blueDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF56C2F0),
    primaryColorLight: const Color(0xFFBED0DE),
    primaryColorDark: const Color.fromARGB(255, 4, 43, 73),
    backgroundColor: const Color.fromARGB(255, 2, 37, 63),
    dialogBackgroundColor: const Color.fromARGB(255, 1, 55, 100),
    cardColor: const Color.fromARGB(255, 2, 74, 133),
    errorColor: const Color(0xFFCF6679),
  ),
};

