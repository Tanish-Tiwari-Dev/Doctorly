import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/domain/models/doctor_review.dart';

void main() {
  group('DoctorReview Unit Tests', () {
    test('fromJson and toJson deserialize and serialize correctly', () {
      final json = {
        'id': 'rev-123',
        'doctor_id': 'doc-456',
        'user_id': 'user-789',
        'rating': 5,
        'comment': 'Excellent doctor, very attentive!',
        'created_at': '2026-08-31T12:00:00.000Z',
      };

      final review = DoctorReview.fromJson(json);

      expect(review.id, 'rev-123');
      expect(review.doctorId, 'doc-456');
      expect(review.userId, 'user-789');
      expect(review.rating, 5);
      expect(review.comment, 'Excellent doctor, very attentive!');

      final serialized = review.toJson();
      expect(serialized['id'], 'rev-123');
      expect(serialized['doctor_id'], 'doc-456');
      expect(serialized['rating'], 5);
    });

    test('copyWith updates properties correctly', () {
      final review = DoctorReview(
        id: '1',
        doctorId: 'doc1',
        userId: 'u1',
        rating: 4,
        createdAt: DateTime.now(),
      );

      final updated = review.copyWith(rating: 5, comment: 'Updated comment');
      expect(updated.rating, 5);
      expect(updated.comment, 'Updated comment');
      expect(updated.id, '1');
    });
  });
}
