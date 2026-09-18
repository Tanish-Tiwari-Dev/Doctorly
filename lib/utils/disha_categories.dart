import 'package:flutter/material.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/utils/doctor_strings.dart';

/// Patient-facing category definitions for the Disha V1 Directory.
class DishaCategory {
  const DishaCategory({
    required this.slug,
    required this.title,
    required this.serviceSlugs,
    required this.icon,
  });

  final String slug;
  final String title;
  final List<String> serviceSlugs;
  final IconData icon;
}

/// The 8 patient-facing categories mapped to internal service slugs.
const List<DishaCategory> dishaCategories = [
  DishaCategory(
    slug: 'trauma',
    title: DoctorStrings.catTraumaTitle,
    serviceSlugs: ['trauma'],
    icon: Icons.personal_injury_outlined,
  ),
  DishaCategory(
    slug: 'brain_tumor',
    title: DoctorStrings.catBrainTumorTitle,
    serviceSlugs: ['brain_tumor'],
    icon: Icons.psychology_outlined,
  ),
  DishaCategory(
    slug: 'spine',
    title: DoctorStrings.catSpineTitle,
    serviceSlugs: ['spine', 'minimally_invasive_spine'],
    icon: Icons.accessibility_new_outlined,
  ),
  DishaCategory(
    slug: 'stroke_neurovascular',
    title: DoctorStrings.catStrokeTitle,
    serviceSlugs: ['stroke', 'neurovascular', 'endovascular'],
    icon: Icons.monitor_heart_outlined,
  ),
  DishaCategory(
    slug: 'skull_base',
    title: DoctorStrings.catSkullBaseTitle,
    serviceSlugs: ['skull_base'],
    icon: Icons.visibility_outlined,
  ),
  DishaCategory(
    slug: 'pediatric',
    title: DoctorStrings.catPediatricTitle,
    serviceSlugs: ['pediatric'],
    icon: Icons.child_care_outlined,
  ),
  DishaCategory(
    slug: 'functional',
    title: DoctorStrings.catFunctionalTitle,
    serviceSlugs: ['functional', 'epilepsy'],
    icon: Icons.electric_bolt_outlined,
  ),
  DishaCategory(
    slug: 'general',
    title: DoctorStrings.catGeneralTitle,
    serviceSlugs: [],
    icon: Icons.medical_services_outlined,
  ),
];


/// Checks if [doctor] offers services matching the specified category [categorySlug].
/// A doctor matches a category if any mapped service slug has a status of 'yes'.
bool doctorMatchesCategory(Doctor doctor, String categorySlug) {
  final category = dishaCategories.firstWhere(
    (c) => c.slug == categorySlug,
    orElse: () => const DishaCategory(
      slug: '',
      title: '',
      serviceSlugs: [],
      icon: Icons.medical_services_outlined,
    ),
  );


  if (category.serviceSlugs.isEmpty) {
    return true;
  }

  for (final serviceSlug in category.serviceSlugs) {
    final status = doctor.serviceStatuses[serviceSlug]?.toLowerCase();
    if (status == 'yes') {
      return true;
    }
  }

  return false;
}
