import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/review.dart';

class ApiReviewRepository {
  final Dio _dio;
  ApiReviewRepository(this._dio);

  Future<List<Review>> mine() => guard(() async {
        final r = await _dio.get('/reviews/my');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Review.fromJson)
            .toList();
      });

  Future<Review> create({
    required int productId,
    required int rating,
    required String text,
  }) =>
      guard(() async {
        final r = await _dio.post('/reviews', data: {
          'productId': productId,
          'rating': rating,
          'text': text,
        });
        return Review.fromJson((r.data as Map).cast<String, dynamic>());
      });

  Future<List<Review>> pending() => guard(() async {
        final r = await _dio.get('/reviews/moderation');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Review.fromJson)
            .toList();
      });

  Future<Review> setStatus(int id, String status) => guard(() async {
        final r =
            await _dio.patch('/reviews/$id/status', data: {'status': status});
        return Review.fromJson((r.data as Map).cast<String, dynamic>());
      });

  Future<List<Review>> forProduct(int productId) => guard(() async {
        final r = await _dio.get('/products/$productId/reviews');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Review.fromJson)
            .toList();
      });
}