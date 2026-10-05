import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/customer.dart';
import 'customer_repository.dart';

class ApiCustomerRepository implements CustomerRepository {
  final Dio _dio;
  ApiCustomerRepository(this._dio);

  @override
  Future<List<Customer>> findAll() => guard(() async {
        final r = await _dio.get('/customers', queryParameters: {'size': 100});
        final data = r.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Customer.fromJson)
            .toList();
      });

  @override
  Future<Customer?> findById(int id) => guard(() async {
        final r = await _dio.get('/customers/$id');
        return Customer.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Customer> create(Customer c) => guard(() async {
        final r = await _dio.post('/customers', data: c.toJson()..remove('id'));
        return Customer.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<Customer> update(Customer c) => guard(() async {
        final r = await _dio.put('/customers/${c.id}', data: c.toJson());
        return Customer.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete('/customers/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/customers/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/customers/$id/restore'));
}