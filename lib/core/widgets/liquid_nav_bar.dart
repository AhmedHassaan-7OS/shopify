import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class LiquidNavBar extends StatelessWidget {
  const LiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(icon: Symbols.home, label: 'الرئيسية'),
    _NavItem(icon: Symbols.search, label: 'البحث'),
    _NavItem(icon: Symbols.favorite, label: 'المفضّلة'),
    _NavItem(icon: Symbols.person, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        bottom: bottomPadding + 12,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x55FFFFFF).withValues(alpha: 0.12)
                  : const Color(0xCCFFFFFF).withValues(alpha: 0.72),
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : const Color(0x44000000),
                width: 0.8,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (int i = 0; i < _items.length; i++)
                    _NavPill(
                      item: _items[i],
                      isSelected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                      activeColor: colors.primary,
                      inactiveColor: colors.onSurfaceVariant,
                      isDark: isDark,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.isDark,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.18 : 0.10)
              : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: isSelected
              ? Border.all(
                  color: activeColor.withValues(alpha: 0.25),
                  width: 0.8,
                )
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isSelected
              ? Row(
                  key: ValueKey<String>('sel-${item.label}'),
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(item.icon, fill: 1, size: 22, color: activeColor),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: activeColor,
                      ),
                    ),
                  ],
                )
              : Icon(
                  key: ValueKey<String>('icon-${item.label}'),
                  item.icon,
                  fill: 0,
                  size: 22,
                  color: inactiveColor,
                ),
        ),
      ),
    );
  }
}
