import 'package:flutter/material.dart';

import '../../core/widgets/animated_orbs_background.dart';
import '../../core/widgets/liquid_nav_bar.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'main_shell_controller.dart';

export 'main_shell_controller.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    this.initialIndex = MainShellController.homeTab,
    this.controller,
  });

  final int initialIndex;
  final MainShellController? controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  MainShellController? _internalController;
  late final MainShellController _controller;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        (_internalController = MainShellController(
          initialIndex: widget.initialIndex,
        ));
    _tabs = <Widget>[
      HomeScreen(onSearchRequested: _controller.openSearchTab),
      SearchScreen(focusNode: _controller.searchFocusNode),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).colorScheme.surface;

    return ValueListenableBuilder<int>(
      valueListenable: _controller.index,
      builder: (BuildContext context, int index, Widget? _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: bg,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(color: bg),
              const IgnorePointer(child: OrbsWidget()),
              IndexedStack(
                index: index,
                children: _tabs
                    .map((tab) => _TransparentTab(child: tab))
                    .toList(),
              ),
            ],
          ),
          bottomNavigationBar: LiquidNavBar(
            selectedIndex: index,
            onDestinationSelected: _controller.selectTab,
          ),
        );
      },
    );
  }
}

class _TransparentTab extends StatelessWidget {
  const _TransparentTab({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: Colors.transparent),
      child: child,
    );
  }
}
