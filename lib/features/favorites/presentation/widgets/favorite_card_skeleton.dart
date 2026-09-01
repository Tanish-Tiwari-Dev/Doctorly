import 'package:flutter/material.dart';

import 'package:doctorly/features/doctor/presentation/widgets/doctor_card_skeleton.dart';

/// Skeleton loading widget matching the layout of a favorite doctor card.
class FavoriteCardSkeleton extends StatelessWidget {
  const FavoriteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorCardSkeleton();
  }
}
