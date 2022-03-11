part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeEvent{}

class ChangeTheme extends ThemeEvent {
  final ThemeInterface theme;

  const ChangeTheme({required this.theme});

  @override
  List<Object> get props => [theme];
}

class ChangeColor extends ThemeEvent {
  final ThemeColor color;

  const ChangeColor({required this.color});

  @override
  List<Object> get props => [color];
}
