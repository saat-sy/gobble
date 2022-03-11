import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/themes/app_themes.dart';
import 'package:gobble/themes/bloc/theme_bloc.dart';

class SettingsBottomModal extends StatelessWidget {
  const SettingsBottomModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bottomSheetTop(context),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Theme",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            switcherContainer(
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
            const Text(
              "Accent Color",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            switcherContainer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  switcherChildColor(
                    context: context,
                    color: appThemeData[AppTheme.blackDark]?.primaryColorLight,
                    text: 'Black',
                    active: state.theme.primaryColor ==
                        appThemeData[AppTheme.blackDark]?.primaryColor,
                    state: state,
                  ),
                  switcherChildColor(
                    context: context,
                    color: appThemeData[AppTheme.blueDark]?.primaryColorLight,
                    text: 'Blue',
                    active: state.theme.primaryColor ==
                        appThemeData[AppTheme.blueDark]?.primaryColor,
                    state: state,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        );
      },
    );
  }

  Container bottomSheetTop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
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
                size: 15,
                color: Colors.grey.shade500,
              ),
            ),
          )
        ],
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
          Navigator.pop(context);
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
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
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
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
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
          Navigator.pop(context);
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
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: active ? Colors.black : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Container switcherContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 12.5,
        horizontal: 35,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 2.5,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 241, 241),
        borderRadius: BorderRadius.circular(50),
      ),
      child: child,
    );
  }
}
