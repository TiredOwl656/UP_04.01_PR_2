import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/customer.dart';
import '../models/loyalty_card.dart';
import 'customer_repository.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  final SupabaseClient _db;
  SupabaseCustomerRepository(this._db);

  @override
  Future<List<Customer>> findAll() => _guard(() async {
    final data = await _db
        .from('customers')
        .select()
        .isFilter('deleted_at', null)
        .order('full_name');

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  @override
  Future<Customer?> findById(int id) => _guard(() async {
    final row = await _db.from('customers').select().eq('id', id).maybeSingle();
    return row == null ? null : _fromRow(row);
  });

  @override
  Future<Customer> create(Customer c) => _guard(() async {
    final row = await _db
        .from('customers')
        .insert({'full_name': c.fullName, 'email': c.email, 'phone': c.phone})
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<Customer> update(Customer c) => _guard(() async {
    final row = await _db
        .from('customers')
        .update({'full_name': c.fullName, 'email': c.email, 'phone': c.phone})
        .eq('id', c.id)
        .select()
        .single();
    return _fromRow(row);
  });

  @override
  Future<void> softDelete(int id) => _guard(() async {
    await _db
        .from('customers')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  });

  @override
  Future<void> hardDelete(int id) =>
      _guard(() => _db.from('customers').delete().eq('id', id));

  @override
  Future<void> restore(int id) => _guard(() async {
    await _db.from('customers').update({'deleted_at': null}).eq('id', id);
  });

  Customer _fromRow(Map<String, dynamic> row) => Customer(
    id: row['id'] as int,
    fullName: row['full_name'] as String? ?? '',
    email: row['email'] as String? ?? '',
    phone: row['phone'] as String? ?? '',
    // LoyaltyCard пока не заведена отдельной таблицей.
    // Если заведём — здесь будет разбор.
    card: null as LoyaltyCard?,
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
