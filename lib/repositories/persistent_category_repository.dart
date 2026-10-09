import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/product_category.dart';
import 'category_repository.dart';

class PersistentCategoryRepository implements CategoryRepository {
  static const _key = 'categories_v1';
  final SharedPreferences _prefs;
  final List<ProductCategory> _categories = [];
  int _nextId = 1;

  PersistentCategoryRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _categories
        ..clear()
        ..addAll(seedCategories);
      _nextId = _categories.length + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _categories
        ..clear()
        ..addAll(list.map((e) =>
            ProductCategory.fromJson((e as Map).cast<String, dynamic>())));
      _nextId = _categories.isEmpty
          ? 1
          : _categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (_) {
      _categories
        ..clear()
        ..addAll(seedCategories);
      _nextId = _categories.length + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<List<ProductCategory>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Возвращаем всё; фильтр "показывать удалённые" — на экране.
    return List.unmodifiable(_categories);
  }

  @override
  Future<ProductCategory?> findById(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    return i == -1 ? null : _categories[i];
  }

  @override
  Future<ProductCategory> create(ProductCategory c) async {
    final created = ProductCategory(
      id: _nextId++,
      name: c.name,
      description: c.description,
    );
    _categories.add(created);
    await _persist();
    return created;
  }

  @override
  Future<ProductCategory> update(ProductCategory c) async {
    final i = _categories.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Категория ${c.id} не найдена');
    _categories[i] = c;
    await _persist();
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Категория $id не найдена');
    _categories[i] = _categories[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _categories.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Категория $id не найдена');
    _categories[i] = _categories[i].copyWith(clearDeletedAt: true);
    await _persist();
  }
}