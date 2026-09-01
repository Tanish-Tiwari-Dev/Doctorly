import 'package:flutter/foundation.dart';

/// Representation of a user review left for a doctor profile.
@immutable
class DoctorReview {
  /// Creates a [DoctorReview] instance.
  const DoctorReview({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  /// Unique identifier of the review.
  final String id;

  /// ID of the doctor being reviewed.
  final String doctorId;

  /// ID of the user authoring the review.
  final String userId;

  /// Integer star rating between 1 and 5.
  final int rating;

  /// Optional text feedback or comment.
  final String? comment;

  /// Timestamp when the review was created.
  final DateTime createdAt;

  /// Constructs a [DoctorReview] from a JSON map returned by Supabase.
  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [DoctorReview] into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [DoctorReview] with modified fields.
  DoctorReview copyWith({
    String? id,
    String? doctorId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return DoctorReview(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorReview &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
