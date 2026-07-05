import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/clients')) return 1;
    if (location.startsWith('/simulator/indicators')) return 3;
    if (location.startsWith('/simulator')) return 2;
    if (location == '/settings') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A1F44).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => context.go(AppRoutes.dashboard),
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  selectedIcon: Icons.group,
                  label: 'Clientes',
                  isSelected: currentIndex == 1,
                  onTap: () => context.go(AppRoutes.clients),
                ),
                _NavItem(
                  icon: Icons.calculate_outlined,
                  selectedIcon: Icons.calculate,
                  label: 'Simulador',
                  isSelected: currentIndex == 2,
                  onTap: () => context.go(AppRoutes.simulator),
                ),
                _NavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: 'Reportes',
                  isSelected: currentIndex == 3,
                  onTap: () => context.go(AppRoutes.financialIndicators),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Configuración',
                  isSelected: currentIndex == 4,
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? AppColors.secondaryContainer
                  : AppColors.onPrimary.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected
                    ? AppColors.secondaryContainer
                    : AppColors.onPrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
