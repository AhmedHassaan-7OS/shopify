import 'package:flutter/widgets.dart';

class MainShellController {
  MainShellController({int initialIndex = homeTab})
    : index = ValueNotifier<int>(_clamp(initialIndex));

  static const int homeTab = 0;
  static const int searchTab = 1;
  static const int favoritesTab = 2;
  static const int profileTab = 3;

  static const int tabCount = 4;

  final ValueNotifier<int> index;

  final FocusNode searchFocusNode = FocusNode(debugLabel: 'searchField');

  void selectTab(int value) {
    if (value < 0 || value >= tabCount) return;
    index.value = value;
  }

  void openSearchTab({bool requestFocus = true}) {
    selectTab(searchTab);
    if (!requestFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (searchFocusNode.context == null) return;
      searchFocusNode.requestFocus();
    });
  }

  void dispose() {
    index.dispose();
    searchFocusNode.dispose();
  }

  static int _clamp(int value) =>
      value < 0 || value >= tabCount ? homeTab : value;
}
