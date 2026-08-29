import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/specialty.dart';
import '../providers/doctor_provider.dart';

class SpecialtyChipSliverDelegate extends SliverPersistentHeaderDelegate {
  const SpecialtyChipSliverDelegate();

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Consumer(
      builder: (context, ref, _) {
        final selected = ref.watch(selectedSpecialtyProvider);
        return Container(
          color: const Color(0xFFF8FAFC),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: selected == null,
                  onSelected: (_) {
                    ref.read(selectedSpecialtyProvider.notifier).state = null;
                  },
                  backgroundColor: const Color(0xFF0A6EBD),
                  selectedColor: const Color(0xFF0A6EBD),
                  disabledColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  showCheckmark: false,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
              for (final s in Specialty.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      s.icon,
                      size: 18,
                      color: selected == s
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                    label: Text(s.label),
                    selected: selected == s,
                    onSelected: (isSelected) {
                      ref.read(selectedSpecialtyProvider.notifier).state =
                          isSelected ? s : null;
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF0A6EBD),
                    labelStyle: GoogleFonts.inter(
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    showCheckmark: false,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant SpecialtyChipSliverDelegate oldDelegate) => false;
}
