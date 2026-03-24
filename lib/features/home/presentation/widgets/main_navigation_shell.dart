import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to flow underneath the floating nav bar
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavBarItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Market',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavBarItem(
                  icon: Icons.favorite_outline_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Wishlist',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                _NavBarItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 4,
                  onTap: () => _onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.antiAlias,
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: 0, height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
