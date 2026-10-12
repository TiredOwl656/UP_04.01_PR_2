import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/review.dart';

class SupabaseReviewRepository {
  final SupabaseClient _db;
  SupabaseReviewRepository(this._db);

  /// Отзывы текущего покупателя (в том числе на модерации).
  Future<List<Review>> mine() => _guard(() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw const UnauthorizedException();

    final customerRow = await _db
        .from('customers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (customerRow == null) return const <Review>[];

    final customerId = customerRow['id'] as int;

    final data = await _db
        .from('reviews')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  /// Одобренные отзывы по конкретному товару.
  Future<List<Review>> forProduct(int productId) => _guard(() async {
    final data = await _db
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  /// Отзывы на модерации (для manager / admin).
  Future<List<Review>> pending() => _guard(() async {
    final data = await _db
        .from('reviews')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  /// Создать отзыв (только customer).
  Future<Review> create({
    required int productId,
    required int rating,
    required String text,
  }) => _guard(() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw const UnauthorizedException();

    final customerRow = await _db
        .from('customers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (customerRow == null) {
      throw const ForbiddenException('Профиль покупателя не найден');
    }
    final customerId = customerRow['id'] as int;

    final row = await _db
        .from('reviews')
        .insert({
          'product_id': productId,
          'customer_id': customerId,
          'rating': rating,
          'text': text,
          'status': 'pending',
        })
        .select()
        .single();
    return _fromRow(row);
  });

  Future<void> hardDelete(int id) => _guard(() async {
    await _db.from('reviews').delete().eq('id', id);
  });

  /// Изменить статус (только manager / admin).
  Future<Review> setStatus(int id, String status) => _guard(() async {
    final row = await _db
        .from('reviews')
        .update({'status': status})
        .eq('id', id)
        .select()
        .single();
    return _fromRow(row);
  });

  Review _fromRow(Map<String, dynamic> row) => Review(
    id: row['id'] as int,
    productId: row['product_id'] as int? ?? 0,
    customerId: row['customer_id'] as int? ?? 0,
    rating: row['rating'] as int? ?? 0,
    text: row['text'] as String? ?? '',
    status: row['status'] as String? ?? 'pending',
    createdAt:
        DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw _mapPostgrest(e);
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw NetworkException('Ошибка сети: $e');
    }
  }

  ApiException _mapPostgrest(PostgrestException e) {
    if (e.code == '23505') return ConflictException(e.message);
    if (e.code == '42501') return ForbiddenException(e.message);
    if (e.code == 'PGRST116') return const NotFoundException();
    return ServerException(e.message);
  }
}
