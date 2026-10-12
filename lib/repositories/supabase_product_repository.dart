import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _db;
  SupabaseProductRepository(this._db);

  @override
  Future<PageResult<Product>> find(ProductQuery q) => _guard(() async {
    var query = _db
        .from('products')
        .select('*, product_categories(category_id)');

    if (!q.includeDeleted) {
      query = query.isFilter('deleted_at', null);
    }
    if (q.search.trim().isNotEmpty) {
      query = query.ilike('name', '%${q.search.trim()}%');
    }
    if (q.brandId != null) {
      query = query.eq('brand_id', q.brandId!);
    }
    if (q.yearFrom != null) {
      query = query.gte('year', q.yearFrom!);
    }
    if (q.yearTo != null) {
      query = query.lte('year', q.yearTo!);
    }

    final countRes = await query.count(CountOption.exact);
    final total = countRes.count;

    final data = await query
        .order(q.sortField, ascending: q.sortAscending)
        .range((q.page - 1) * q.size, q.page * q.size - 1);

    final items = (data as List)
        .cast<Map<String, dynamic>>()
        .map(_fromRow)
        .toList();

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  });

  Product _fromRow(Map<String, dynamic> row) {
    final cats =
        (row['product_categories'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map((c) => c['category_id'] as int)
            .toList() ??
        const <int>[];

    return Product(
      id: row['id'] as int,
      name: row['name'] as String? ?? '',
      sku: row['sku'] as String? ?? '',
      brandId: row['brand_id'] as int? ?? 0,
      supplierId: row['supplier_id'] as int? ?? 0,
      categoryIds: cats,
      size: row['size'] as String? ?? '',
      color: row['color'] as String? ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      stock: row['stock'] as int? ?? 0,
      year: row['year'] as int? ?? 0,
      deletedAt: row['deleted_at'] == null
          ? null
          : DateTime.tryParse(row['deleted_at'] as String),
    );
  }

  @override
  Future<Product?> findById(int id) => _guard(() async {
    final row = await _db
        .from('products')
        .select('*, product_categories(category_id)')
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  });

  @override
  Future<Product> create(Product p) => _guard(() async {
    final row = await _db
        .from('products')
        .insert({
          'name': p.name,
          'sku': p.sku,
          'brand_id': p.brandId,
          'supplier_id': p.supplierId,
          'size': p.size,
          'color': p.color,
          'price': p.price,
          'stock': p.stock,
          'year': p.year,
        })
        .select()
        .single();

    final id = row['id'] as int;

    if (p.categoryIds.isNotEmpty) {
      await _db
          .from('product_categories')
          .insert(
            p.categoryIds
                .map((c) => {'product_id': id, 'category_id': c})
                .toList(),
          );
    }

    return _fromRow({...row, 'product_categories': []});
  });

  @override
  Future<Product> update(Product p) => _guard(() async {
    await _db
        .from('products')
        .update({
          'name': p.name,
          'sku': p.sku,
          'brand_id': p.brandId,
          'supplier_id': p.supplierId,
          'size': p.size,
          'color': p.color,
          'price': p.price,
          'stock': p.stock,
          'year': p.year,
        })
        .eq('id', p.id);

    // Полная замена категорий
    await _db.from('product_categories').delete().eq('product_id', p.id);
    if (p.categoryIds.isNotEmpty) {
      await _db
          .from('product_categories')
          .insert(
            p.categoryIds
                .map((c) => {'product_id': p.id, 'category_id': c})
                .toList(),
          );
    }

    return p;
  });

  @override
  Future<void> softDelete(int id) => _guard(() async {
    await _db
        .from('products')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  });

  @override
  Future<void> hardDelete(int id) =>
      _guard(() => _db.from('products').delete().eq('id', id));

  @override
  Future<void> restore(int id) => _guard(() async {
    await _db.from('products').update({'deleted_at': null}).eq('id', id);
  });

  @override
  Future<int> deleteMany(List<int> ids) => _guard(() async {
    await _db
        .from('products')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .inFilter('id', ids);
    return ids.length;
  });

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
    if (e.code == 'PGRST116') return NotFoundException();
    return ServerException(e.message);
  }
}
