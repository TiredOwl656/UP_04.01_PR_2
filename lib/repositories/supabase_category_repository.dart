import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/product_category.dart';
import 'category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  final SupabaseClient _db;
  SupabaseCategoryRepository(this._db);

  // Простой кэш справочника — категории меняются редко.
  List<ProductCategory>? _cache;

  @override
  Future<List<ProductCategory>> findAll() => _guard(() async {
    if (_cache != null) return _cache!;

    final data = await _db.from('categories').select().order('name');

    _cache = (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
    return _cache!;
  });

  @override
  Future<ProductCategory?> findById(int id) => _guard(() async {
    final row = await _db
        .from('categories')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  });

  @override
  Future<ProductCategory> create(ProductCategory c) => _guard(() async {
    _cache = null;
    final row = await _db
        .from('categories')
        .insert({'name': c.name, 'description': c.description})
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<ProductCategory> update(ProductCategory c) => _guard(() async {
    _cache = null;
    final row = await _db
        .from('categories')
        .update({'name': c.name, 'description': c.description})
        .eq('id', c.id)
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<void> softDelete(int id) => _guard(() async {
    _cache = null;
    await _db
        .from('categories')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  });

  @override
  Future<void> hardDelete(int id) => _guard(() async {
    _cache = null;
    await _db.from('categories').delete().eq('id', id);
  });

  @override
  Future<void> restore(int id) => _guard(() async {
    _cache = null;
    await _db.from('categories').update({'deleted_at': null}).eq('id', id);
  });

  ProductCategory _fromRow(Map<String, dynamic> row) => ProductCategory(
    id: row['id'] as int,
    name: row['name'] as String? ?? '',
    description: row['description'] as String? ?? '',
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
