import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gobble/strings/strings.dart';
import 'package:gobble/themes/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(
          ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData),
        ) {
    on<ThemeInitial>(_themeInitial);
    on<ChangeTheme>(_changeTheme);
    on<ChangeColor>(_changeColor);
  }

  void _themeInitial(ThemeInitial event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString(GobbleStrings.theme);
    AppTheme finalTheme;

    if (theme != null) {
      theme = theme.split('.')[1];
      if (theme.startsWith("black")) {
        if (theme.endsWith("Light")) {
          finalTheme = AppTheme.blackLight;
        } else {
          finalTheme = AppTheme.blackDark;
        }
      } else {
        if (theme.endsWith("Light")) {
          finalTheme = AppTheme.blueLight;
        } else {
          finalTheme = AppTheme.blueDark;
        }
      }
      emit(ThemeState(theme: appThemeData[finalTheme] as ThemeData));
    } else {
      emit(ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData));
    }
  }

  void _changeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    String themeString = "";
    if (state.theme.primaryColor ==
        appThemeData[AppTheme.blackLight]?.primaryColor) {
      if (event.theme == ThemeInterface.light) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData));
        themeString = AppTheme.blackLight.toString();
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blackDark] as ThemeData));
        themeString = AppTheme.blackDark.toString();
      }
    } else {
      if (event.theme == ThemeInterface.light) {
        emit(ThemeState(theme: appThemeData[AppTheme.blueLight] as ThemeData));
        themeString = AppTheme.blueLight.toString();
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueDark] as ThemeData));
        themeString = AppTheme.blueDark.toString();
      }
    }

    print(themeString);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(GobbleStrings.theme, themeString);
  }

  void _changeColor(ChangeColor event, Emitter<ThemeState> emit) async {
    String themeString = "";
    if (state.theme.brightness == Brightness.light) {
      if (event.color == ThemeColor.black) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackLight] as ThemeData));
        themeString = AppTheme.blackLight.toString();
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueLight] as ThemeData));
        themeString = AppTheme.blueLight.toString();
      }
    } else {
      if (event.color == ThemeColor.black) {
        emit(ThemeState(theme: appThemeData[AppTheme.blackDark] as ThemeData));
        themeString = AppTheme.blackDark.toString();
      } else {
        emit(ThemeState(theme: appThemeData[AppTheme.blueDark] as ThemeData));
        themeString = AppTheme.blueDark.toString();
      }
    }

    print(themeString);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(GobbleStrings.theme, themeString);
  }
}
