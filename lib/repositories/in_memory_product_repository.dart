import '../data/seed_data.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _products = [...seedProducts];
  int _nextId = seedProducts.length + 1;

  @override
  Future<PageResult<Product>> find(ProductQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _products
        .where((p) => q.includeDeleted || !p.isDeleted)
        .toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (p) =>
                p.name.toLowerCase().contains(needle) ||
                p.sku.toLowerCase().contains(needle),
          )
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
    return created;
  }

  @override
  Future<Product> update(Product p) async {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i == -1) throw StateError('Товар ${p.id} не найден');
    _products[i] = p;
    return p;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Товар $id не найден');
    _products[i] = _products[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Товар $id не найден');
    _products[i] = _products[i].copyWith(clearDeletedAt: true);
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
    return count;
  }
}
