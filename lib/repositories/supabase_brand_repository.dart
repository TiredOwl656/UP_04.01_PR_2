import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/page_result.dart';
import 'brand_repository.dart';

class SupabaseBrandRepository implements BrandRepository {
  final SupabaseClient _db;
  SupabaseBrandRepository(this._db);

  @override
  Future<PageResult<Brand>> find(BrandQuery q) => _guard(() async {
    var query = _db.from('brands').select();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim();
      query = query.or('name.ilike.%$needle%,country.ilike.%$needle%');
    }

    final countRes = await query.count(CountOption.exact);
    final total = countRes.count;

    final data = await query
        .order(q.sortField, ascending: q.sortAscending)
        .range((q.page - 1) * q.size, q.page * q.size - 1);

    final items = (data as List)
        .cast<Map<String, dynamic>>()
        .map(_fromRow)
        .toList();

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  });

  @override
  Future<Brand?> findById(int id) => _guard(() async {
    final row = await _db.from('brands').select().eq('id', id).maybeSingle();
    return row == null ? null : _fromRow(row);
  });

  @override
  Future<Brand> create(Brand b) => _guard(() async {
    final row = await _db
        .from('brands')
        .insert({
          'name': b.name,
          'country': b.country,
          'founded_year': b.foundedYear,
        })
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<Brand> update(Brand b) => _guard(() async {
    final row = await _db
        .from('brands')
        .update({
          'name': b.name,
          'country': b.country,
          'founded_year': b.foundedYear,
        })
        .eq('id', b.id)
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<void> softDelete(int id) => _guard(() async {
    await _db
        .from('brands')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  });

  @override
  Future<void> hardDelete(int id) =>
      _guard(() => _db.from('brands').delete().eq('id', id));

  @override
  Future<void> restore(int id) => _guard(() async {
    await _db.from('brands').update({'deleted_at': null}).eq('id', id);
  });

  Brand _fromRow(Map<String, dynamic> row) => Brand(
    id: row['id'] as int,
    name: row['name'] as String? ?? '',
    country: row['country'] as String? ?? '',
    foundedYear: row['founded_year'] as int? ?? 0,
    deletedAt: row['deleted_at'] == null
        ? null
        : DateTime.tryParse(row['deleted_at'] as String),
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
