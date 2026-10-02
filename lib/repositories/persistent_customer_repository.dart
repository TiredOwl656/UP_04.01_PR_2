import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/customer.dart';
import 'customer_repository.dart';

class PersistentCustomerRepository implements CustomerRepository {
  static const _key = 'customers_v1';
  final SharedPreferences _prefs;
  final List<Customer> _customers = [];
  int _nextId = 1;

  PersistentCustomerRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _customers
        ..clear()
        ..addAll(seedCustomers);
      _nextId = _customers.length + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _customers
        ..clear()
        ..addAll(list.map(
            (e) => Customer.fromJson((e as Map).cast<String, dynamic>())));
      _nextId = _customers.isEmpty
          ? 1
          : _customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (_) {
      _customers
        ..clear()
        ..addAll(seedCustomers);
      _nextId = _customers.length + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_customers.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<List<Customer>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_customers.where((c) => !c.isDeleted));
  }

  @override
  Future<Customer?> findById(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    return i == -1 ? null : _customers[i];
  }

  Future<bool> isEmailTaken(String email, {int? exceptId}) async {
    final needle = email.trim().toLowerCase();
    return _customers
        .any((c) => c.email.toLowerCase() == needle && c.id != exceptId);
  }

  @override
  Future<Customer> create(Customer c) async {
    final created = Customer(
      id: _nextId++,
      fullName: c.fullName,
      email: c.email,
      phone: c.phone,
      card: c.card,
    );
    _customers.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Customer> update(Customer c) async {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Покупатель ${c.id} не найден');
    _customers[i] = c;
    await _persist();
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Покупатель $id не найден');
    _customers[i] = _customers[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _customers.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Покупатель $id не найден');
    _customers[i] = _customers[i].copyWith(clearDeletedAt: true);
    await _persist();
  }
}