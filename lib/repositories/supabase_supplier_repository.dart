import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/supplier.dart';
import 'supplier_repository.dart';

class SupabaseSupplierRepository implements SupplierRepository {
  final SupabaseClient _db;
  SupabaseSupplierRepository(this._db);

  List<Supplier>? _cache;

  @override
  Future<List<Supplier>> findAll() => _guard(() async {
    if (_cache != null) return _cache!;

    final data = await _db.from('suppliers').select().order('name');

    _cache = (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
    return _cache!;
  });

  @override
  Future<Supplier?> findById(int id) => _guard(() async {
    final row = await _db.from('suppliers').select().eq('id', id).maybeSingle();
    return row == null ? null : _fromRow(row);
  });

  @override
  Future<Supplier> create(Supplier s) => _guard(() async {
    _cache = null;
    final row = await _db
        .from('suppliers')
        .insert({
          'name': s.name,
          'country': s.country,
          'email': s.email,
          'phone': s.phone,
        })
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<Supplier> update(Supplier s) => _guard(() async {
    _cache = null;
    final row = await _db
        .from('suppliers')
        .update({
          'name': s.name,
          'country': s.country,
          'email': s.email,
          'phone': s.phone,
        })
        .eq('id', s.id)
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<void> softDelete(int id) => _guard(() async {
    _cache = null;
    await _db
        .from('suppliers')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  });

  @override
  Future<void> hardDelete(int id) => _guard(() async {
    _cache = null;
    await _db.from('suppliers').delete().eq('id', id);
  });

  @override
  Future<void> restore(int id) => _guard(() async {
    _cache = null;
    await _db.from('suppliers').update({'deleted_at': null}).eq('id', id);
  });

  Supplier _fromRow(Map<String, dynamic> row) => Supplier(
    id: row['id'] as int,
    name: row['name'] as String? ?? '',
    country: row['country'] as String? ?? '',
    email: row['email'] as String? ?? '',
    phone: row['phone'] as String? ?? '',
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
