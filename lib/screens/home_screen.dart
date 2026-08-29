import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor.dart';
import '../models/specialty.dart';
import '../providers/doctor_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _nearbyActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleNearMe() async {
    try {
      final granted =
          await ref.read(locationServiceProvider).requestPermission();
      if (!mounted) return;

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location denied, showing default nearby doctors.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
        return;
      }

      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      if (!mounted) return;

      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get your location.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
        return;
      }

      final client = ref.read(supabaseClientProvider);
      final res = await client.rpc('nearby_doctors', params: {
        'lat': position.latitude,
        'lng': position.longitude,
        'radius_km': 5.0,
      });

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map(_doctorFromRpc)
          .toList();

      ref.read(nearbyResultsProvider.notifier).state = list;
      setState(() => _nearbyActive = true);

      if (!mounted) return;
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No doctors within 5 km.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Showing ${list.length} doctor${list.length == 1 ? '' : 's'} within 5 km.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location denied, showing default nearby doctors.',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  Doctor _doctorFromRpc(Map<String, dynamic> row) => Doctor.fromJson(row);

  @override
  Widget build(BuildContext context) {
    final asyncDoctors = ref.watch(doctorListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: asyncDoctors.when(
          loading: () => const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0A6EBD)),
                ),
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
                  ),
                ),
              ),
            ],
          ),
          data: (_) {
            final topRated = ref.watch(topRatedDoctorsProvider).valueOrNull ?? const <Doctor>[];
            final filtered = ref.watch(filteredDoctorsProvider);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Welcome back 👋',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find your doctor',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _nearbyActive
                                  ? Icons.location_off
                                  : Icons.near_me,
                              color: const Color(0xFF0A6EBD),
                            ),
                            tooltip: 'Near Me',
                            onPressed: _handleNearMe,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search doctors, specialties…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SpecialtyChipDelegate(ref),
                ),
                if (topRated.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'Top Rated',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 8,
                            ),
                            itemCount: topRated.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => SizedBox(
                              width: 240,
                              child: DoctorCard(doctor: topRated[i], compact: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: 'No doctors found',
                        subtitle: 'Try a different search or filter.',
                      ),
                    ),
                  )
                else
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.crossAxisExtent < 600) {
                        return SliverList.separated(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final doctor = filtered[index];
                            return DoctorCard(doctor: doctor);
                          },
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                        );
                      }
                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doctor = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: DoctorCard(doctor: doctor),
                            );
                          },
                          childCount: filtered.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.6,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpecialtyChipDelegate extends SliverPersistentHeaderDelegate {
  _SpecialtyChipDelegate(this.ref);

  final WidgetRef ref;

  @override
  double get minExtent => 64.0;

  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final selected = ref.watch(selectedSpecialtyProvider);
    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) {
                ref.read(selectedSpecialtyProvider.notifier).state = null;
              },
              showCheckmark: false,
            ),
          ),
          for (final s in Specialty.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(s.icon, size: 18),
                label: Text(s.label),
                selected: selected == s,
                onSelected: (isSelected) {
                  ref.read(selectedSpecialtyProvider.notifier).state =
                      isSelected ? s : null;
                },
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SpecialtyChipDelegate oldDelegate) =>
      oldDelegate.ref != ref;
}
