import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gobble/strings/strings.dart';
import 'package:gobble/themes/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required int themeIndex})
      : super(
          ThemeState(theme: appThemeData.entries.elementAt(themeIndex).value),
        ) {
    on<ChangeTheme>(_changeTheme);
    on<ChangeColor>(_changeColor);
  }

  void _changeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    int themeIndex = 0;
    if (state.theme.primaryColor ==
        appThemeData[AppTheme.blackLight]?.primaryColor) {
      if (event.theme == ThemeInterface.light) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData));
        themeIndex = 0;
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blackDark] as ThemeData));
        themeIndex = 1;
      }
    } else {
      if (event.theme == ThemeInterface.light) {
        emit(ThemeState(theme: appThemeData[AppTheme.blueLight] as ThemeData));
        themeIndex = 2;
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueDark] as ThemeData));
        themeIndex = 3;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(GobbleStrings.theme, themeIndex);
  }

  void _changeColor(ChangeColor event, Emitter<ThemeState> emit) async {
    int themeString = 0;
    if (state.theme.brightness == Brightness.light) {
      if (event.color == ThemeColor.black) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData));
        themeString = 0;
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueLight] as ThemeData));
        themeString = 1;
      }
    } else {
      if (event.color == ThemeColor.black) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackDark] as ThemeData));
        themeString = 2;
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueDark] as ThemeData));
        themeString = 3;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(GobbleStrings.theme, themeString);
  }
}
