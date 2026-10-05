import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/supplier.dart';
import 'supplier_repository.dart';

class ApiSupplierRepository implements SupplierRepository {
  final Dio _dio;
  ApiSupplierRepository(this._dio);

  List<Supplier>? _cache;

  @override
  Future<List<Supplier>> findAll() => guard(() async {
        if (_cache != null) return _cache!;
        final r = await _dio.get('/suppliers', queryParameters: {'size': 100});
        final data = r.data as Map<String, dynamic>;
        _cache = (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Supplier.fromJson)
            .toList();
        return _cache!;
      });

  void invalidateCache() => _cache = null;

  @override
  Future<Supplier?> findById(int id) => guard(() async {
        final r = await _dio.get('/suppliers/$id');
        return Supplier.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Supplier> create(Supplier s) => guard(() async {
        invalidateCache();
        final r = await _dio.post('/suppliers', data: s.toJson()..remove('id'));
        return Supplier.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Supplier> update(Supplier s) => guard(() async {
        invalidateCache();
        final r = await _dio.put('/suppliers/${s.id}', data: s.toJson());
        return Supplier.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) => guard(() async {
        invalidateCache();
        await _dio.delete('/suppliers/$id');
      });

  @override
  Future<void> hardDelete(int id) => guard(() async {
        invalidateCache();
        await _dio.delete('/suppliers/$id', queryParameters: {'hard': true});
      });

  @override
  Future<void> restore(int id) => guard(() async {
        invalidateCache();
        await _dio.post('/suppliers/$id/restore');
      });
}