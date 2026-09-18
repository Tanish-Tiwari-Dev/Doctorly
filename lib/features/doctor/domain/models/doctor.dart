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
    this.externalId,
    this.address,
    this.distanceMeters,
    this.qualification,
    this.subSpecialty,
    this.designation,
    this.hospitalName,
    this.practiceType,
    this.district,
    this.city,
    this.pinCode,
    this.mobile,
    this.whatsapp,
    this.hospitalPhone,
    this.emergencyContact,
    this.email,
    this.websiteUrl,
    this.teleconsultation = false,
    this.teleconsultationStatus = 'unknown',
    this.emergency24x7 = 'unknown',
    this.languages,
    this.languagesList = const [],
    this.expertise = const {},
    this.openingTime = '09:00',
    this.closingTime = '17:00',
    this.opdDays = const [],
    this.opdOpen,
    this.opdClose,
    this.opdByAppointment = false,
    this.councilName,
    this.registrationNo,
    this.registrationState,
    this.registrationStatus,
    this.registrationVerifiedOn,
    this.sourceType,
    this.primarySourceUrl,
    this.secondarySourceUrl,
    this.remarks,
    this.verifiedBy,
    this.lastVerifiedAt,
    this.verificationStatus = 'unverified',
    this.dataStatus = 'published',
    this.isVerified = false,
    this.yearsOfExperience = 0,
    this.about,
    this.serviceStatuses = const {},
  });

  final String id;
  final String name;
  final String specialty;
  final double distanceKm;
  final double rating;
  final String imageUrl;
  final String availability;
  final String? externalId;
  final String? address;
  final double? distanceMeters;
  final String? qualification;
  final String? subSpecialty;
  final String? designation;
  final String? hospitalName;
  final String? practiceType;
  final String? district;
  final String? city;
  final String? pinCode;
  final String? mobile;
  final String? whatsapp;
  final String? hospitalPhone;
  final String? emergencyContact;
  final String? email;
  final String? websiteUrl;
  final bool teleconsultation;
  final String teleconsultationStatus;
  final String emergency24x7;
  final String? languages;
  final List<String> languagesList;
  final Map<String, bool> expertise;
  final String openingTime;
  final String closingTime;
  final List<String> opdDays;
  final String? opdOpen;
  final String? opdClose;
  final bool opdByAppointment;
  final String? councilName;
  final String? registrationNo;
  final String? registrationState;
  final String? registrationStatus;
  final String? registrationVerifiedOn;
  final String? sourceType;
  final String? primarySourceUrl;
  final String? secondarySourceUrl;
  final String? remarks;
  final String? verifiedBy;
  final String? lastVerifiedAt;
  final String verificationStatus; // 'unverified', 'partially_verified', 'verified'
  final String dataStatus; // 'draft', 'in_review', 'published', 'rejected', 'test'
  final bool isVerified;
  final int yearsOfExperience;
  final String? about;
  final Map<String, String> serviceStatuses;

  bool get isFullyVerified =>
      verificationStatus == 'verified' || isVerified == true;

  bool get isPartiallyVerified =>
      verificationStatus == 'partially_verified';

  bool get isUnverified =>
      !isFullyVerified && !isPartiallyVerified;

  bool get isAvailableToday {
    final lower = availability.toLowerCase();
    return lower.contains('today') ||
        lower.contains('available') ||
        lower.contains('open');
  }

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

    List<String> langList = [];
    if (json['languages'] is List) {
      langList = (json['languages'] as List).map((e) => e.toString()).toList();
    } else if (json['languages'] is String && (json['languages'] as String).isNotEmpty) {
      langList = (json['languages'] as String).split(',').map((s) => s.trim()).toList();
    }

    List<String> opdList = [];
    if (json['opd_days'] is List) {
      opdList = (json['opd_days'] as List).map((e) => e.toString()).toList();
    }

    Map<String, String> serviceMap = {};
    if (json['doctor_services'] is List) {
      for (final item in json['doctor_services'] as List) {
        if (item is Map) {
          final service = item['services'];
          final slug = service is Map ? service['slug'] as String? : null;
          final status = item['status'] as String?;
          if (slug != null && status != null) {
            serviceMap[slug] = status;
          }
        }
      }
    } else if (json['service_statuses'] is Map) {
      (json['service_statuses'] as Map).forEach((key, value) {
        serviceMap[key.toString()] = value.toString();
      });
    }

    final rawVerificationStatus = json['verification_status'] as String?;
    final rawIsVerified = json['is_verified'] as bool? ?? false;
    final resolvedVerificationStatus = rawVerificationStatus ??
        (rawIsVerified ? 'verified' : 'unverified');

    final teleconsultVal = json['teleconsultation'];
    final bool teleconsultBool = teleconsultVal == true ||
        teleconsultVal == 'yes';
    final String teleconsultStr = teleconsultVal is String
        ? teleconsultVal
        : (teleconsultVal == true ? 'yes' : (teleconsultVal == false ? 'no' : 'unknown'));

    return Doctor(
      id: (json['id'] as String?) ?? '',
      name: (json['full_name'] as String?) ?? (json['name'] as String?) ?? '',
      specialty: (json['primary_specialty'] as String?) ??
          (json['specialty'] as String?) ??
          '',
      distanceKm: distanceM != null ? distanceM / 1000.0 : 0.0,
      rating: (json['average_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          0.0,
      imageUrl: (json['image_url'] as String?) ?? '',
      availability: (json['availability'] as String?) ?? '',
      externalId: json['external_id'] as String?,
      address: json['address'] as String?,
      distanceMeters: distanceM,
      qualification: json['qualification'] as String?,
      subSpecialty: json['sub_specialty'] as String?,
      designation: json['designation'] as String?,
      hospitalName: json['hospital_name'] as String?,
      practiceType: json['practice_type'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      pinCode: json['pin_code'] as String?,
      mobile: (json['mobile'] as String?) ?? (json['phone_number'] as String?) ?? (json['phone'] as String?),
      whatsapp: json['whatsapp'] as String?,
      hospitalPhone: json['hospital_phone'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      teleconsultation: teleconsultBool,
      teleconsultationStatus: teleconsultStr,
      emergency24x7: (json['emergency_24x7'] as String?) ?? 'unknown',
      languages: json['languages'] is String ? json['languages'] as String : langList.join(', '),
      languagesList: langList,
      expertise: expertiseMap,
      openingTime: (json['opd_open'] as String?) ?? (json['opening_time'] as String?) ?? '09:00',
      closingTime: (json['opd_close'] as String?) ?? (json['closing_time'] as String?) ?? '17:00',
      opdDays: opdList,
      opdOpen: json['opd_open'] as String?,
      opdClose: json['opd_close'] as String?,
      opdByAppointment: (json['opd_by_appointment'] as bool?) ?? false,
      councilName: json['council_name'] as String?,
      registrationNo: json['registration_no'] as String?,
      registrationState: json['registration_state'] as String?,
      registrationStatus: json['registration_status'] as String?,
      registrationVerifiedOn: json['registration_verified_on']?.toString(),
      sourceType: json['source_type'] as String?,
      primarySourceUrl: json['primary_source_url'] as String?,
      secondarySourceUrl: json['secondary_source_url'] as String?,
      remarks: json['remarks'] as String?,
      verifiedBy: json['verified_by'] as String?,
      lastVerifiedAt: json['last_verified_at']?.toString(),
      verificationStatus: resolvedVerificationStatus,
      dataStatus: (json['data_status'] as String?) ?? 'published',
      isVerified: resolvedVerificationStatus == 'verified',
      yearsOfExperience: (json['years_experience'] as num?)?.toInt() ??
          (json['years_of_experience'] as num?)?.toInt() ??
          0,
      about: json['about'] as String?,
      serviceStatuses: serviceMap,
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
      'external_id': externalId,
      'address': address,
      'qualification': qualification,
      'sub_specialty': subSpecialty,
      'designation': designation,
      'hospital_name': hospitalName,
      'practice_type': practiceType,
      'district': district,
      'city': city,
      'pin_code': pinCode,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'hospital_phone': hospitalPhone,
      'emergency_contact': emergencyContact,
      'email': email,
      'website_url': websiteUrl,
      'teleconsultation': teleconsultationStatus,
      'emergency_24x7': emergency24x7,
      'languages': languagesList.isNotEmpty ? languagesList : languages,
      'expertise': expertise,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'opd_days': opdDays,
      'opd_open': opdOpen,
      'opd_close': opdClose,
      'opd_by_appointment': opdByAppointment,
      'council_name': councilName,
      'registration_no': registrationNo,
      'registration_state': registrationState,
      'registration_status': registrationStatus,
      'registration_verified_on': registrationVerifiedOn,
      'source_type': sourceType,
      'primary_source_url': primarySourceUrl,
      'secondary_source_url': secondarySourceUrl,
      'remarks': remarks,
      'verified_by': verifiedBy,
      'last_verified_at': lastVerifiedAt,
      'verification_status': verificationStatus,
      'data_status': dataStatus,
      'is_verified': isVerified,
      'years_experience': yearsOfExperience,
      'years_of_experience': yearsOfExperience,
      'about': about,
      'service_statuses': serviceStatuses,
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    double? distanceKm,
    double? rating,
    String? imageUrl,
    String? availability,
    String? externalId,
    String? address,
    double? distanceMeters,
    String? qualification,
    String? subSpecialty,
    String? designation,
    String? hospitalName,
    String? practiceType,
    String? district,
    String? city,
    String? pinCode,
    String? mobile,
    String? whatsapp,
    String? hospitalPhone,
    String? emergencyContact,
    String? email,
    String? websiteUrl,
    bool? teleconsultation,
    String? teleconsultationStatus,
    String? emergency24x7,
    String? languages,
    List<String>? languagesList,
    Map<String, bool>? expertise,
    String? openingTime,
    String? closingTime,
    List<String>? opdDays,
    String? opdOpen,
    String? opdClose,
    bool? opdByAppointment,
    String? councilName,
    String? registrationNo,
    String? registrationState,
    String? registrationStatus,
    String? registrationVerifiedOn,
    String? sourceType,
    String? primarySourceUrl,
    String? secondarySourceUrl,
    String? remarks,
    String? verifiedBy,
    String? lastVerifiedAt,
    String? verificationStatus,
    String? dataStatus,
    bool? isVerified,
    int? yearsOfExperience,
    String? about,
    Map<String, String>? serviceStatuses,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      availability: availability ?? this.availability,
      externalId: externalId ?? this.externalId,
      address: address ?? this.address,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      qualification: qualification ?? this.qualification,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      designation: designation ?? this.designation,
      hospitalName: hospitalName ?? this.hospitalName,
      practiceType: practiceType ?? this.practiceType,
      district: district ?? this.district,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      mobile: mobile ?? this.mobile,
      whatsapp: whatsapp ?? this.whatsapp,
      hospitalPhone: hospitalPhone ?? this.hospitalPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      email: email ?? this.email,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      teleconsultation: teleconsultation ?? this.teleconsultation,
      teleconsultationStatus: teleconsultationStatus ?? this.teleconsultationStatus,
      emergency24x7: emergency24x7 ?? this.emergency24x7,
      languages: languages ?? this.languages,
      languagesList: languagesList ?? this.languagesList,
      expertise: expertise ?? this.expertise,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      opdDays: opdDays ?? this.opdDays,
      opdOpen: opdOpen ?? this.opdOpen,
      opdClose: opdClose ?? this.opdClose,
      opdByAppointment: opdByAppointment ?? this.opdByAppointment,
      councilName: councilName ?? this.councilName,
      registrationNo: registrationNo ?? this.registrationNo,
      registrationState: registrationState ?? this.registrationState,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registrationVerifiedOn: registrationVerifiedOn ?? this.registrationVerifiedOn,
      sourceType: sourceType ?? this.sourceType,
      primarySourceUrl: primarySourceUrl ?? this.primarySourceUrl,
      secondarySourceUrl: secondarySourceUrl ?? this.secondarySourceUrl,
      remarks: remarks ?? this.remarks,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      dataStatus: dataStatus ?? this.dataStatus,
      isVerified: isVerified ?? this.isVerified,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      about: about ?? this.about,
      serviceStatuses: serviceStatuses ?? this.serviceStatuses,
    );
  }
}
