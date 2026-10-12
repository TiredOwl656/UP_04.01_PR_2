import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Role {
  customer('Покупатель'),
  manager('Менеджер'),
  admin('Администратор');

  final String label;
  const Role(this.label);

  static Role fromName(String? name) => switch (name) {
    'admin' => Role.admin,
    'manager' => Role.manager,
    _ => Role.customer,
  };
}

class AuthNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) {
    _supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  User? get user => _supabase.auth.currentUser;
  Session? get session => _supabase.auth.currentSession;
  bool get isAuthenticated => user != null;

  String? get email => user?.email;
  String? get fullName => user?.userMetadata?['full_name'] as String?;

  Role get role {
    final name = user?.userMetadata?['role'] as String?;
    return Role.fromName(name);
  }

  // ---------- Покупатель ----------
  bool get canBrowseCatalog => isAuthenticated;
  bool get canPlaceOrder => role == Role.customer;
  bool get canViewOwnOrders => role == Role.customer;
  bool get canUseLoyalty => role == Role.customer;

  // ---------- Менеджер и админ ----------
  bool get canViewAllOrders => role == Role.manager || role == Role.admin;
  bool get canModerateReviews => role == Role.manager || role == Role.admin;
  bool get canProcessOrders => role == Role.manager || role == Role.admin;

  // ---------- Только админ ----------
  bool get canManageCatalog => role == Role.admin;
  bool get canManageUsers => role == Role.admin;
  bool get canViewAudit => role == Role.admin;

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
