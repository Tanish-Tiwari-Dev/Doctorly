import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavScaffold extends StatelessWidget {
  const BottomNavScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: Color(0xFF94A3B8)),
      selectedIcon: Icon(Icons.home, color: Color(0xFF0A6EBD)),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border, color: Color(0xFF94A3B8)),
      selectedIcon: Icon(Icons.favorite, color: Color(0xFF0A6EBD)),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8)),
      selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF0A6EBD)),
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
                      const Color(0xFF0A6EBD).withValues(alpha: 0.12),
                  selectedIconTheme:
                      const IconThemeData(color: Color(0xFF0A6EBD), size: 24),
                  unselectedIconTheme:
                      const IconThemeData(color: Color(0xFF64748B), size: 24),
                  selectedLabelTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A6EBD),
                  ),
                  unselectedLabelTextStyle: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
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
                  color: Color(0xFFE5E7EB),
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
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
