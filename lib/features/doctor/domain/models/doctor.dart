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
    this.qualification,
    this.subSpecialty,
    this.designation,
    this.hospitalName,
    this.practiceType,
    this.city,
    this.phone,
    this.email,
    this.websiteUrl,
    this.teleconsultation = false,
    this.languages,
    this.expertise = const {},
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
  final String? qualification;
  final String? subSpecialty;
  final String? designation;
  final String? hospitalName;
  final String? practiceType;
  final String? city;
  final String? phone;
  final String? email;
  final String? websiteUrl;
  final bool teleconsultation;
  final String? languages;
  final Map<String, bool> expertise;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final double? distanceM = (json['distance_m'] as num?)?.toDouble();

    Map<String, bool> expertiseMap = {};
    if (json['expertise'] != null) {
      if (json['expertise'] is Map) {
        (json['expertise'] as Map).forEach((key, value) {
          expertiseMap[key.toString()] = value == true;
        });
      }
    }

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
      qualification: json['qualification'] as String?,
      subSpecialty: json['sub_specialty'] as String?,
      designation: json['designation'] as String?,
      hospitalName: json['hospital_name'] as String?,
      practiceType: json['practice_type'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      teleconsultation: (json['teleconsultation'] as bool?) ?? false,
      languages: json['languages'] as String?,
      expertise: expertiseMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'image_url': imageUrl,
      'availability': availability,
      'address': address,
      'qualification': qualification,
      'sub_specialty': subSpecialty,
      'designation': designation,
      'hospital_name': hospitalName,
      'practice_type': practiceType,
      'city': city,
      'phone': phone,
      'email': email,
      'website_url': websiteUrl,
      'teleconsultation': teleconsultation,
      'languages': languages,
      'expertise': expertise,
    };
  }

  Doctor copyWith({
    double? distanceKm,
    double? distanceMeters,
    String? qualification,
    String? subSpecialty,
    String? designation,
    String? hospitalName,
    String? practiceType,
    String? city,
    String? phone,
    String? email,
    String? websiteUrl,
    bool? teleconsultation,
    String? languages,
    Map<String, bool>? expertise,
  }) {
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
      qualification: qualification ?? this.qualification,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      designation: designation ?? this.designation,
      hospitalName: hospitalName ?? this.hospitalName,
      practiceType: practiceType ?? this.practiceType,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      teleconsultation: teleconsultation ?? this.teleconsultation,
      languages: languages ?? this.languages,
      expertise: expertise ?? this.expertise,
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
