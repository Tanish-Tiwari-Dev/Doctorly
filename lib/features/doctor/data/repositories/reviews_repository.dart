import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/features/doctor/domain/models/doctor_review.dart';
import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository for fetching and submitting doctor reviews.
class ReviewsRepository {
  /// Creates a [ReviewsRepository] with the given [SupabaseClient].
  ReviewsRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all reviews for the specified [doctorId].
  Future<List<DoctorReview>> fetchReviews(String doctorId) async {
    try {
      final response = await _client
          .from('doctor_reviews')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DoctorReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Submits a new review for [doctorId] with a [rating] (1-5) and optional [comment].
  Future<DoctorReview> submitReview({
    required String doctorId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const RepositoryException(
        RepositoryExceptionKind.unauthorized,
        'User is not authenticated',
      );
    }

    try {
      final response = await _client
          .from('doctor_reviews')
          .insert({
            'doctor_id': doctorId,
            'user_id': userId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return DoctorReview.fromJson(response);
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [ReviewsRepository].
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.read(supabaseClientProvider));
});

/// Provider for fetching reviews for a specific doctor ID.
final doctorReviewsProvider =
    FutureProvider.family<List<DoctorReview>, String>((ref, doctorId) async {
  final repository = ref.watch(reviewsRepositoryProvider);
  return repository.fetchReviews(doctorId);
});
