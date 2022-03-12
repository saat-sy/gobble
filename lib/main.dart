import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/strings/strings.dart';
import 'package:gobble/themes/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puzzle/puzzle.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  _getThemeIndex() {
    int? value = prefs.getInt(GobbleStrings.theme);
    if (value != null) {
      return value;
    } else {
      var brightness = SchedulerBinding.instance!.window.platformBrightness;
      if (brightness == Brightness.dark) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(themeIndex: _getThemeIndex()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.theme,
            home: const PuzzlePage(),
          );
        },
      ),
    );
  }
}
