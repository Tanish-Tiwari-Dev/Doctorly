import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/auth/presentation/providers/auth_provider.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/widgets/offline_banner.dart';

class BottomNavScaffold extends ConsumerWidget {
  const BottomNavScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMerging = ref.watch(isMergingProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      final mergeError = next.valueOrNull?.mergeError;
      if (mergeError != null && mergeError.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              mergeError,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        );
        ref.read(authProvider.notifier).clearMergeError();
      }
    });

    final items = [
      (
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      (
        label: 'Favorites',
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded,
      ),
      (
        label: 'Appointments',
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_month_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final mainContent = Column(
          children: [
            const OfflineBanner(),
            if (isMerging) const _MergeProgressBanner(),
            Expanded(child: navigationShell),
          ],
        );

        if (isWide) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FC),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onTap,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFE6F7F8),
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xFF0A7E8C),
                    size: 24,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Color(0xFF9CA3AF),
                    size: 24,
                  ),
                  selectedLabelTextStyle: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A7E8C),
                  ),
                  unselectedLabelTextStyle: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                  destinations: items
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.activeIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Color(0xFFE5E7EB),
                ),
                Expanded(child: mainContent),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: mainContent,
          bottomNavigationBar: Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A1A2B33),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = index == navigationShell.currentIndex;
                  final item = items[index];

                  return Expanded(
                    child: InkWell(
                      onTap: () => _onTap(index),
                      splashColor: const Color(0xFFE6F7F8),
                      highlightColor: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 44,
                          minWidth: 44,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE6F7F8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 24,
                                color: isSelected
                                    ? const Color(0xFF0A7E8C)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? const Color(0xFF0A7E8C)
                                    : const Color(0xFF9CA3AF),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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

class _MergeProgressBanner extends StatelessWidget {
  const _MergeProgressBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Finalizing your account...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
