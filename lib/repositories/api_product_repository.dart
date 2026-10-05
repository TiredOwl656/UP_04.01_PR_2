import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class ApiProductRepository implements ProductRepository {
  final Dio _dio;
  ApiProductRepository(this._dio);

  CancelToken? _searchToken;

  @override
  Future<PageResult<Product>> find(ProductQuery q) => guard(() async {
        // Отменяем предыдущий поиск — п.13
        _searchToken?.cancel('Заменён новым запросом');
        _searchToken = CancelToken();

        final response = await _dio.get(
          '/products',
          cancelToken: _searchToken,
          queryParameters: {
            if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
            if (q.brandId != null) 'brandId': q.brandId,
            if (q.categoryId != null) 'categoryId': q.categoryId,
            if (q.yearFrom != null) 'yearFrom': q.yearFrom,
            if (q.yearTo != null) 'yearTo': q.yearTo,
            'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
            'page': q.page,
            'size': q.size,
            if (q.includeDeleted) 'includeDeleted': true,
          },
        );

        final data = response.data as Map<String, dynamic>;
        return PageResult(
          items: (data['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList(),
          page: data['page'] as int? ?? 1,
          size: data['size'] as int? ?? q.size,
          total: data['total'] as int? ?? 0,
        );
      });

  @override
  Future<Product?> findById(int id) => guard(() async {
        final r = await _dio.get('/products/$id');
        return Product.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Product> create(Product p) => guard(() async {
        final r = await _dio.post('/products', data: p.toJson()..remove('id'));
        return Product.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Product> update(Product p) => guard(() async {
        final r = await _dio.put('/products/${p.id}', data: p.toJson());
        return Product.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete('/products/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/products/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/products/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
        final r = await _dio.post('/products/bulk-delete', data: {'ids': ids});
        return (r.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
      });
}