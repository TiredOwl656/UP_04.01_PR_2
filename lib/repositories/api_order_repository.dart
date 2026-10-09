import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/order.dart';

class ApiOrderRepository {
  final Dio _dio;
  ApiOrderRepository(this._dio);

  Future<Order> create(List<OrderItem> items) => guard(() async {
        final r = await _dio.post('/orders', data: {
          'items': items.map((it) => it.toJson()).toList(),
        });
        return Order.fromJson((r.data as Map).cast<String, dynamic>());
      });

  Future<List<Order>> myOrders() => guard(() async {
        final r = await _dio.get('/orders/my');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList();
      });

  Future<void> cancel(int id) => guard(() => _dio.post('/orders/$id/cancel'));

  Future<List<Order>> all() => guard(() async {
        final r = await _dio.get('/orders');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList();
      });

  Future<Order> setStatus(int id, String status) => guard(() async {
        final r =
            await _dio.patch('/orders/$id/status', data: {'status': status});
        return Order.fromJson((r.data as Map).cast<String, dynamic>());
      });
}