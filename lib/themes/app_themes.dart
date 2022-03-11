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
  ),
  AppTheme.blackDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF353535),
    primaryColorLight: const Color(0xFFFFFFFF),
    primaryColorDark: const Color(0xFF353535),
    backgroundColor: const Color(0xFF353535),
    dialogBackgroundColor: Color.fromARGB(255, 70, 70, 70)
  ),
  AppTheme.blueLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 0, 67, 119),
    primaryColorLight: const Color.fromARGB(255, 0, 67, 119),
    primaryColorDark: const Color(0xFFFFFFFF),
    backgroundColor: const Color(0xFFFFFFFF),
    dialogBackgroundColor: const Color(0xFFFFFFFF),
  ),
  AppTheme.blueDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF56C2F0),
    primaryColorLight: const Color(0xFFBED0DE),
    primaryColorDark: const Color.fromARGB(255, 4, 43, 73),
    backgroundColor: const Color.fromARGB(255, 4, 43, 73),
    dialogBackgroundColor: Color.fromARGB(255, 1, 49, 87),
  ),
};

