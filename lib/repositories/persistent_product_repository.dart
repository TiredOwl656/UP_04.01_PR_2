import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class PersistentProductRepository implements ProductRepository {
  static const _key = 'products_v1';
  final SharedPreferences _prefs;
  final List<Product> _products = [];
  int _nextId = 1;

  PersistentProductRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _products
        ..clear()
        ..addAll(seedProducts);
      _nextId = _products.length + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _products
        ..clear()
        ..addAll(list.map(
            (e) => Product.fromJson((e as Map).cast<String, dynamic>())));
      _nextId = _products.isEmpty
          ? 1
          : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (_) {
      _products
        ..clear()
        ..addAll(seedProducts);
      _nextId = _products.length + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_products.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Future<PageResult<Product>> find(ProductQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows =
        _products.where((p) => q.includeDeleted || !p.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((p) =>
              p.name.toLowerCase().contains(needle) ||
              p.sku.toLowerCase().contains(needle))
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((p) => p.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.brandId != null) {
      rows = rows.where((p) => p.brandId == q.brandId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((p) => p.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((p) => p.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'price' => a.price.compareTo(b.price),
        'stock' => a.stock.compareTo(b.stock),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? r : -r;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Product>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Product?> findById(int id) async {
    final i = _products.indexWhere((p) => p.id == id);
    return i == -1 ? null : _products[i];
  }

  Future<bool> isSkuTaken(String sku, {int? exceptId}) async {
    final needle = sku.trim().toLowerCase();
    return _products
        .any((p) => p.sku.toLowerCase() == needle && p.id != exceptId);
  }

  Future<int> countBySupplier(int supplierId) async {
    return _products.where((p) => p.supplierId == supplierId).length;
  }

  Future<int> countByBrand(int brandId) async {
    return _products.where((p) => p.brandId == brandId).length;
  }

  Future<int> countByCategory(int categoryId) async {
    return _products.where((p) => p.categoryIds.contains(categoryId)).length;
  }

  @override
  Future<Product> create(Product p) async {
    final created = Product(
      id: _nextId++,
      name: p.name,
      sku: p.sku,
      brandId: p.brandId,
      supplierId: p.supplierId,
      categoryIds: p.categoryIds,
      size: p.size,
      color: p.color,
      price: p.price,
      stock: p.stock,
      year: p.year,
    );
    _products.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Product> update(Product p) async {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i == -1) throw StateError('Товар ${p.id} не найден');
    _products[i] = p;
    await _persist();
    return p;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Товар $id не найден');
    _products[i] = _products[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _products.removeWhere((p) => p.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Товар $id не найден');
    _products[i] = _products[i].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _products.indexWhere((p) => p.id == id && !p.isDeleted);
      if (i != -1) {
        _products[i] = _products[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _persist();
    return count;
  }
}