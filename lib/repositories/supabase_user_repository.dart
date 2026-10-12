import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../state/auth_notifier.dart' show Role;

/// Модель пользователя для админского экрана.
/// Отдельная от Supabase User, потому что нам нужны id в customers
/// и роль из user_roles — их в auth.users нет.
class ManagedUser {
  final int customerId; // customers.id
  final String userId; // auth.users.id (uuid)
  final String email;
  final String fullName;
  final Role role;

  const ManagedUser({
    required this.customerId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });
}

class SupabaseUserRepository {
  final SupabaseClient _db;
  SupabaseUserRepository(this._db);

  /// Все пользователи с ролями. Доступно только admin (RLS).
  Future<List<ManagedUser>> all() async {
    try {
      final customers = await _db
          .from('customers')
          .select('id, user_id, full_name, email')
          .order('full_name');

      final roles = await _db.from('user_roles').select('user_id, role');

      final roleByUser = <String, String>{
        for (final r in (roles as List).cast<Map<String, dynamic>>())
          r['user_id'] as String: r['role'] as String,
      };

      return (customers as List).cast<Map<String, dynamic>>().map((row) {
        final uid = row['user_id'] as String? ?? '';
        return ManagedUser(
          customerId: row['id'] as int,
          userId: uid,
          email: row['email'] as String? ?? '',
          fullName: row['full_name'] as String? ?? '',
          role: Role.fromName(roleByUser[uid]),
        );
      }).toList();
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw const ForbiddenException();
      }
      throw ServerException(e.message);
    } catch (e) {
      throw NetworkException('Ошибка сети: $e');
    }
  }

  /// Сменить роль. Только admin.
  Future<void> setRole(String userId, Role role) async {
    try {
      await _db.from('user_roles').delete().eq('user_id', userId);
      await _db.from('user_roles').insert({
        'user_id': userId,
        'role': role.name,
      });
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw const ForbiddenException();
      }
      throw ServerException(e.message);
    }
  }

  /// Заблокировать пользователя (soft delete профиля).
  Future<void> softDelete(int customerId) async {
    try {
      await _db
          .from('customers')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', customerId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
