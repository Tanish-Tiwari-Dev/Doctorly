import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class BottomNavScaffold extends StatelessWidget {
  const BottomNavScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: AppColors.inactiveIcon),
      selectedIcon: Icon(Icons.home, color: AppColors.primary),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border, color: AppColors.inactiveIcon),
      selectedIcon: Icon(Icons.favorite, color: AppColors.primary),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined, color: AppColors.inactiveIcon),
      selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
      label: 'Appointments',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onTap,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  indicatorColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary, size: 24),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.textSecondary, size: 24),
                  selectedLabelTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  unselectedLabelTextStyle: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('Appointments'),
                    ),
                  ],
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: AppColors.divider,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: navigationShell,
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: _destinations,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
