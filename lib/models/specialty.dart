import 'package:flutter/material.dart';

enum Specialty {
  cardiology('Cardiologist', Icons.favorite),
  dermatology('Dermatologist', Icons.face),
  pediatrics('Pediatrician', Icons.child_care),
  orthopedics('Orthopedic Surgeon', Icons.accessibility_new),
  generalPractice('General Physician', Icons.medical_services),
  dentistry('Dentist', Icons.medical_information);

  const Specialty(this.label, this.icon);

  final String label;
  final IconData icon;

  static Specialty? fromLabel(String label) {
    for (final s in Specialty.values) {
      if (s.label == label) return s;
    }
    return null;
  }
}
