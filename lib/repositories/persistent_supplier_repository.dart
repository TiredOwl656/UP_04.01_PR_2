import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/supplier.dart';
import 'supplier_repository.dart';

class PersistentSupplierRepository implements SupplierRepository {
  static const _key = 'suppliers_v1';
  final SharedPreferences _prefs;
  final List<Supplier> _suppliers = [];
  int _nextId = 1;

  PersistentSupplierRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _suppliers
        ..clear()
        ..addAll(seedSuppliers);
      _nextId = _suppliers.length + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _suppliers
        ..clear()
        ..addAll(list.map(
            (e) => Supplier.fromJson((e as Map).cast<String, dynamic>())));
      _nextId = _suppliers.isEmpty
          ? 1
          : _suppliers.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (_) {
      _suppliers
        ..clear()
        ..addAll(seedSuppliers);
      _nextId = _suppliers.length + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_suppliers.map((s) => s.toJson()).toList()),
    );
  }

  @override
  Future<List<Supplier>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Возвращаем всё; фильтр "показывать удалённые" — на экране.
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<Supplier?> findById(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    return i == -1 ? null : _suppliers[i];
  }

  @override
  Future<Supplier> create(Supplier s) async {
    final created = Supplier(
      id: _nextId++,
      name: s.name,
      country: s.country,
      email: s.email,
      phone: s.phone,
    );
    _suppliers.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Supplier> update(Supplier s) async {
    final i = _suppliers.indexWhere((x) => x.id == s.id);
    if (i == -1) throw StateError('РџРѕСЃС‚Р°РІС‰РёРє ${s.id} РЅРµ РЅР°Р№РґРµРЅ');
    _suppliers[i] = s;
    await _persist();
    return s;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i == -1) throw StateError('РџРѕСЃС‚Р°РІС‰РёРє $id РЅРµ РЅР°Р№РґРµРЅ');
    _suppliers[i] = _suppliers[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _suppliers.removeWhere((s) => s.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i == -1) throw StateError('РџРѕСЃС‚Р°РІС‰РёРє $id РЅРµ РЅР°Р№РґРµРЅ');
    _suppliers[i] = _suppliers[i].copyWith(clearDeletedAt: true);
    await _persist();
  }
}