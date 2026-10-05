import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/page_result.dart';
import 'brand_repository.dart';

class ApiBrandRepository implements BrandRepository {
  final Dio _dio;
  ApiBrandRepository(this._dio);

  @override
  Future<PageResult<Brand>> find(BrandQuery q) => guard(() async {
        final r = await _dio.get('/brands', queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
        });
        final data = r.data as Map<String, dynamic>;
        return PageResult(
          items: (data['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Brand.fromJson)
              .toList(),
          page: data['page'] as int? ?? 1,
          size: data['size'] as int? ?? q.size,
          total: data['total'] as int? ?? 0,
        );
      });

  @override
  Future<Brand?> findById(int id) => guard(() async {
        final r = await _dio.get('/brands/$id');
        return Brand.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Brand> create(Brand b) => guard(() async {
        final r = await _dio.post('/brands', data: b.toJson()..remove('id'));
        return Brand.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Brand> update(Brand b) => guard(() async {
        final r = await _dio.put('/brands/${b.id}', data: b.toJson());
        return Brand.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete('/brands/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/brands/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/brands/$id/restore'));
}