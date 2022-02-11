import 'package:flutter/material.dart';
import 'package:gobble/colors/colors.dart';

class DefaultBuilder extends StatefulWidget {
  const DefaultBuilder({Key? key}) : super(key: key);

  @override
  _DefaultBuilderState createState() => _DefaultBuilderState();
}

class _DefaultBuilderState extends State<DefaultBuilder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const double tabHeight = 35;
  static const double marginTop = 80;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            children: const [
              PuzzleBoard(
                  singlePlayer: true,
                  tabHeight: tabHeight,
                  marginForTab: marginTop),
              PuzzleBoard(
                  singlePlayer: false,
                  tabHeight: tabHeight,
                  marginForTab: marginTop)
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
              border: Border.all(color: GobbleColors.black, width: 1)),
          child: Align(alignment: Alignment.center, child: Text(title)),
        ),
      ),
    );
  }
}

class PuzzleBoard extends StatefulWidget {
  final bool singlePlayer;
  final double tabHeight;
  final double marginForTab;

  const PuzzleBoard(
      {required this.singlePlayer,
      required this.tabHeight,
      required this.marginForTab,
      Key? key})
      : super(key: key);

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  // BOARD WIDTH
  late double sideOfBoard;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sideOfBoard = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Center(
          child: Container(
              margin: EdgeInsets.only(
                  bottom: widget.tabHeight + widget.marginForTab),
              width: sideOfBoard,
              height: sideOfBoard,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  itemCount: 36,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemBuilder: (context, index) => getPiece()
                  )
                ),
        ),
      ],
    );
  }

  Container getPiece() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
