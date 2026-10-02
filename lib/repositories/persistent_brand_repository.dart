import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/page_result.dart';
import 'brand_repository.dart';

class PersistentBrandRepository implements BrandRepository {
  static const _key = 'brands_v1';
  final SharedPreferences _prefs;
  final List<Brand> _brands = [];
  int _nextId = 1;

  PersistentBrandRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _brands
        ..clear()
        ..addAll(seedBrands);
      _nextId = _brands.length + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _brands
        ..clear()
        ..addAll(list.map(
            (e) => Brand.fromJson((e as Map).cast<String, dynamic>())));
      _nextId = _brands.isEmpty
          ? 1
          : _brands.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (_) {
      _brands
        ..clear()
        ..addAll(seedBrands);
      _nextId = _brands.length + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_brands.map((b) => b.toJson()).toList()),
    );
  }

  @override
  Future<PageResult<Brand>> find(BrandQuery q) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var rows = _brands.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.name.toLowerCase().contains(needle) ||
              b.country.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'country' =>
          a.country.toLowerCase().compareTo(b.country.toLowerCase()),
        'founded' => a.foundedYear.compareTo(b.foundedYear),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? r : -r;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Brand>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Brand?> findById(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    return i == -1 ? null : _brands[i];
  }

  @override
  Future<Brand> create(Brand b) async {
    final created = Brand(
      id: _nextId++,
      name: b.name,
      country: b.country,
      foundedYear: b.foundedYear,
    );
    _brands.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Brand> update(Brand b) async {
    final i = _brands.indexWhere((x) => x.id == b.id);
    if (i == -1) throw StateError('Бренд ${b.id} не найден');
    _brands[i] = b;
    await _persist();
    return b;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бренд $id не найден');
    _brands[i] = _brands[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _brands.removeWhere((b) => b.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бренд $id не найден');
    _brands[i] = _brands[i].copyWith(clearDeletedAt: true);
    await _persist();
  }
}