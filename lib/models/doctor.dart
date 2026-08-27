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
    this.address,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String specialty;
  final double distanceKm;
  final double rating;
  final String imageUrl;
  final String availability;
  final String? address;
  final double? distanceMeters;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final double? distanceM = (json['distance_m'] as num?)?.toDouble();
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      distanceKm: distanceM != null ? distanceM / 1000.0 : 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['image_url'] as String?) ?? '',
      availability: (json['availability'] as String?) ?? '',
      address: json['address'] as String?,
      distanceMeters: distanceM,
    );
  }

  Doctor copyWith({double? distanceKm, double? distanceMeters}) {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating,
      imageUrl: imageUrl,
      availability: availability,
      address: address,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  bool get isAvailableToday =>
      availability.trim().toLowerCase().contains('today');

  @override
  String toString() => 'Doctor(id: $id, name: $name, specialty: $specialty)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
