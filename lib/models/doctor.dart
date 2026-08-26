import 'package:flutter/material.dart';

@immutable
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.distanceKm,
    required this.rating,
    required this.imageUrl,
    required this.availability,
  });

  final int id;
  final String name;
  final String specialty;
  final double distanceKm;
  final double rating;
  final String imageUrl;
  final String availability;

  @override
  String toString() => 'Doctor(id: $id, name: $name, specialty: $specialty)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
