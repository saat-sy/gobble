import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobble/mode/mode_bloc.dart';
import 'package:gobble/colors/colors.dart';
import 'package:gobble/puzzle/puzzle.dart';
import 'package:gobble/puzzle/widgets/puzzle_board.dart';

class DefaultBuilder extends StatefulWidget {
  const DefaultBuilder({
    Key? key,
  }) : super(key: key);

  @override
  _DefaultBuilderState createState() => _DefaultBuilderState();
}

class _DefaultBuilderState extends State<DefaultBuilder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const double tabHeight = 35;
  static const double marginTop = 60;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onModeChange);
    super.initState();
  }

  // CHANGE MODE IF THE TABS ARE CHANGED IN MODEBLOC
  _onModeChange() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          context.read<ModeBloc>().add(ChangeModeToSingle());
          break;
        case 1:
          context.read<ModeBloc>().add(ChangeModeToMulti());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: marginTop,
        ),
        TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: GobbleColors.black),
          labelColor: GobbleColors.textLight,
          unselectedLabelColor: GobbleColors.textDark,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          indicatorWeight: 0,
          labelStyle: const TextStyle(
            fontSize: 15,
          ),

          // TABS
          tabs: [
            getTab("SINGLE PLAYER"),
            getTab("1 v 1"),
          ],
        ),

        // CHILDREN
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              PuzzleBoard(
                puzzle: context.read<PuzzleBloc>().state.puzzle,
                tabHeight: tabHeight,
                marginForTab: marginTop,
              ),
              PuzzleBoard(
                puzzle: context.read<PuzzleBloc>().state.puzzle,
                tabHeight: tabHeight,
                marginForTab: marginTop,
              ),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox getTab(String title) {
    return SizedBox(
      height: tabHeight,
      child: Tab(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: GobbleColors.black,
              width: 1,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(title),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
