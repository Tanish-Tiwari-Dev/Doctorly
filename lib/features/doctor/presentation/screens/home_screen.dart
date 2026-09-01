import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/doctor/data/repositories/doctors_repository.dart';
import 'package:doctorly/features/doctor/domain/models/specialty.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/widgets/doctor_card.dart';
import 'package:doctorly/features/doctor/presentation/widgets/doctor_card_skeleton.dart';
import 'package:doctorly/features/doctor/presentation/widgets/doctor_filter_sheet.dart';
import 'package:doctorly/features/doctor/presentation/widgets/top_rated_doctor_card.dart';
import 'package:doctorly/providers/location_provider.dart';
import 'package:doctorly/services/location_service.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFetchingLocation = false;
  bool _nearbyActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleNearMe() async {
    if (_isFetchingLocation) return;

    if (_nearbyActive) {
      ref.read(nearbyResultsProvider.notifier).state = null;
      setState(() => _nearbyActive = false);
      return;
    }

    setState(() => _isFetchingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();

      if (!mounted) return;

      final filter = ref.read(doctorFilterProvider);
      final list = await ref.read(doctorRepositoryProvider).fetchNearby(
            position.latitude,
            position.longitude,
            filter: filter,
          );

      if (!mounted) return;

      ref.read(nearbyResultsProvider.notifier).state = list;
      setState(() {
        _nearbyActive = true;
        _isFetchingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            list.isEmpty
                ? 'No doctors found near your current location.'
                : 'Found ${list.length} doctor${list.length == 1 ? '' : 's'} near you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingLocation = false);

      final String errorMessage = e is LocationException
          ? e.message
          : 'Could not fetch your current location.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDoctors = ref.watch(doctorListProvider);
    final topRatedAsync = ref.watch(topRatedDoctorsProvider);
    final searchQuery = ref.watch(searchQueryProvider).trim();
    final activeFilter = ref.watch(doctorFilterProvider);
    final selectedSpecialty = ref.watch(selectedSpecialtyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: asyncDoctors.when(
          loading: () => CustomScrollView(
            slivers: [
              SliverList.builder(
                itemCount: 6,
                itemBuilder: (context, index) => const DoctorCardSkeleton(),
              ),
            ],
          ),
          error: (e, _) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: EmptyState(
                    icon: Icons.cloud_off,
                    title: 'Error',
                    subtitle: 'Could not load doctors.',
                    onRetry: () => ref.invalidate(doctorListProvider),
                  ),
                ),
              ),
            ],
          ),
          data: (_) {
            final filtered = ref.watch(filteredDoctorsProvider);
            final isSearching = searchQuery.isNotEmpty;

            return CustomScrollView(
              slivers: [
                // 1. SliverAppBar with Search Bar and Specialty Quick Chips embedded in bottom
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  elevation: 0,
                  backgroundColor: const Color(0xFFF7F9FC),
                  automaticallyImplyLeading: false,
                  toolbarHeight: 56,
                  titleSpacing: DesignTokens.md,
                  title: Text(
                    'Find your specialist',
                    style: theme.textTheme.headlineMedium,
                  ),
                  actions: [
                    IconButton(
                      icon: _isFetchingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0A7E8C),
                                ),
                              ),
                            )
                          : Icon(
                              _nearbyActive
                                  ? Icons.near_me
                                  : Icons.near_me_outlined,
                              color: _nearbyActive
                                  ? const Color(0xFF0A7E8C)
                                  : const Color(0xFF6B7280),
                            ),
                      tooltip: _nearbyActive ? 'Show All Doctors' : 'Near Me',
                      onPressed: _isFetchingLocation ? null : _handleNearMe,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF0A7E8C),
                      ),
                      tooltip: 'Settings',
                      onPressed: () => context.push('/settings'),
                    ),
                    const SizedBox(width: DesignTokens.xs),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(124),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.md,
                            vertical: DesignTokens.xs,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F6),
                              borderRadius: BorderRadius.circular(30.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    size: 22,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        ref
                                            .read(searchQueryProvider.notifier)
                                            .setQuery(value);
                                      },
                                      style: theme.textTheme.bodyMedium,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Search doctors, specialties…',
                                        hintStyle: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        ref
                                            .read(searchQueryProvider.notifier)
                                            .setQuery('');
                                      },
                                      child: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => DoctorFilterSheet.show(context),
                                    child: Badge(
                                      isLabelVisible: !activeFilter.isDefault,
                                      backgroundColor: const Color(0xFF0A7E8C),
                                      smallSize: 8,
                                      child: const Icon(
                                        Icons.tune_rounded,
                                        size: 22,
                                        color: Color(0xFF0A7E8C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Specialty Quick Chips: Horizontal ListView with 12px spacing
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.md,
                            ),
                            itemCount: Specialty.values.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final specialty = Specialty.values[index];
                              final isSelected = selectedSpecialty == specialty;
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedSpecialtyProvider.notifier)
                                      .state = isSelected ? null : specialty;
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0A7E8C)
                                        : const Color(0xFFF1F3F6),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        specialty.icon,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4B5563),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        specialty.label,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: DesignTokens.xs),
                      ],
                    ),
                  ),
                ),

                // Sections when not actively searching
                if (!isSearching) ...[
                  // 2. Top Rated Section with 16px top padding
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.md,
                        DesignTokens.md,
                        DesignTokens.md,
                        DesignTokens.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Rated',
                            style: theme.textTheme.titleLarge,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Optional see all action
                            },
                            child: Text(
                              'See All',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF0A7E8C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Horizontal Carousel for Top Rated Doctor Cards
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 150,
                      child: topRatedAsync.when(
                        loading: () => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.md,
                          ),
                          itemCount: 3,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, _) => Container(
                            width: 180,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(DesignTokens.large),
                              boxShadow: const [DesignTokens.cardShadow],
                            ),
                          ),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (doctors) => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.md,
                          ),
                          itemCount: doctors.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              TopRatedDoctorCard(doctor: doctors[index]),
                        ),
                      ),
                    ),
                  ),

                  // 3. All Doctors Section Header with 24px top padding
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.md,
                        DesignTokens.lg,
                        DesignTokens.md,
                        DesignTokens.sm,
                      ),
                      child: Text(
                        'All Doctors',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.md,
                        DesignTokens.md,
                        DesignTokens.md,
                        DesignTokens.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Search Results',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            '${filtered.length} found',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 4. All Doctors List with 16px separator between items
                if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: 'No doctors found',
                        subtitle: 'Try a different search term or filter.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.lg),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: DesignTokens.md),
                      itemBuilder: (context, index) => DoctorCard(
                        doctor: filtered[index],
                        compact: false,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
