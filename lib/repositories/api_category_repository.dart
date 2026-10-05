import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/product_category.dart';
import 'category_repository.dart';

class ApiCategoryRepository implements CategoryRepository {
  final Dio _dio;
  ApiCategoryRepository(this._dio);

  // Кэш справочника — п.15
  List<ProductCategory>? _cache;

  @override
  Future<List<ProductCategory>> findAll() => guard(() async {
        if (_cache != null) return _cache!;
        final r = await _dio.get('/categories', queryParameters: {'size': 100});
        final data = r.data as Map<String, dynamic>;
        _cache = (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ProductCategory.fromJson)
            .toList();
        return _cache!;
      });

  void invalidateCache() => _cache = null;

  @override
  Future<ProductCategory?> findById(int id) => guard(() async {
        final r = await _dio.get('/categories/$id');
        return ProductCategory.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<ProductCategory> create(ProductCategory c) => guard(() async {
        invalidateCache();
        final r = await _dio.post('/categories', data: c.toJson()..remove('id'));
        return ProductCategory.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<ProductCategory> update(ProductCategory c) => guard(() async {
        invalidateCache();
        final r = await _dio.put('/categories/${c.id}', data: c.toJson());
        return ProductCategory.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) => guard(() async {
        invalidateCache();
        await _dio.delete('/categories/$id');
      });

  @override
  Future<void> hardDelete(int id) => guard(() async {
        invalidateCache();
        await _dio.delete('/categories/$id', queryParameters: {'hard': true});
      });

  @override
  Future<void> restore(int id) => guard(() async {
        invalidateCache();
        await _dio.post('/categories/$id/restore');
      });
}