import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/themes/app_themes.dart';
import 'package:gobble/themes/bloc/theme_bloc.dart';
import 'package:responsive_framework/responsive_value.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class SettingsBottomModal extends StatelessWidget {
  const SettingsBottomModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveValue(context, defaultValue: 0.0, valueWhen: [
                  Condition.equals(
                      name: TABLET,
                      value: MediaQuery.of(context).size.width * 0.015),
                  Condition.equals(
                      name: DESKTOP,
                      value: MediaQuery.of(context).size.width * 0.25),
                  Condition.equals(
                      name: 'XL',
                      value: MediaQuery.of(context).size.width * 0.325),
                ]).value ??
                0.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bottomSheetTop(context),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Theme",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                ),
                switcherContainer(
                  context: context,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      switcherChildTheme(
                        context: context,
                        icon: CupertinoIcons.sun_min,
                        brightness: state.theme.brightness,
                        active: state.theme.brightness == Brightness.light,
                      ),
                      switcherChildTheme(
                        context: context,
                        icon: CupertinoIcons.moon,
                        brightness: state.theme.brightness,
                        active: state.theme.brightness == Brightness.dark,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Accent Color",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                ),
                switcherContainer(
                  context: context,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      switcherChildColor(
                        context: context,
                        color: appThemeData[AppTheme.blackDark]?.primaryColor,
                        text: 'Black',
                        active: state.theme.primaryColor ==
                            appThemeData[AppTheme.blackDark]?.primaryColor,
                        state: state,
                      ),
                      switcherChildColor(
                        context: context,
                        color: appThemeData[AppTheme.blueDark]?.primaryColor,
                        text: 'Blue',
                        active: state.theme.primaryColor ==
                                appThemeData[AppTheme.blueDark]?.primaryColor ||
                            state.theme.primaryColor ==
                                appThemeData[AppTheme.blueLight]?.primaryColor,
                        state: state,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Sounds",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                ),
                switcherContainer(
                  context: context,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      switcherSoundsTheme(
                        context: context,
                        icon: CupertinoIcons.speaker_slash_fill,
                        brightness: state.theme.brightness,
                        // TODO: ADD ACTUAL LOGIC
                        active: false,
                      ),
                      switcherSoundsTheme(
                        context: context,
                        icon: CupertinoIcons.speaker_fill,
                        brightness: state.theme.brightness,
                        active: true,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container bottomSheetTop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : const Color.fromARGB(255, 240, 240, 240)),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'GOBBLE SETTINGS',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_down,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
          )
        ],
      ),
    );
  }

  Expanded switcherSoundsTheme(
      {required BuildContext context,
      required IconData icon,
      required Brightness brightness,
      required bool active}) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).dialogBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: active
                  ? Theme.of(context).primaryColorLight
                  : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Expanded switcherChildColor(
      {required BuildContext context,
      required String text,
      required Color? color,
      required bool active,
      required ThemeState state}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          if (!active) {
            if (text == "Black") {
              context
                  .read<ThemeBloc>()
                  .add(const ChangeColor(color: ThemeColor.black));
            } else {
              context
                  .read<ThemeBloc>()
                  .add(const ChangeColor(color: ThemeColor.blue));
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).dialogBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(width: 7.5),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: active
                      ? Theme.of(context).primaryColorLight
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded switcherChildTheme(
      {required BuildContext context,
      required IconData icon,
      required Brightness brightness,
      required bool active}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!active) {
            if (brightness == Brightness.light) {
              context
                  .read<ThemeBloc>()
                  .add(const ChangeTheme(theme: ThemeInterface.dark));
            } else {
              context
                  .read<ThemeBloc>()
                  .add(const ChangeTheme(theme: ThemeInterface.light));
            }
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).dialogBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: active
                  ? Theme.of(context).primaryColorLight
                  : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Container switcherContainer(
      {required Widget child, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 12.5,
        horizontal: 45,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 2.5,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : const Color.fromARGB(255, 240, 240, 240),
        borderRadius: BorderRadius.circular(50),
      ),
      child: child,
    );
  }
}
