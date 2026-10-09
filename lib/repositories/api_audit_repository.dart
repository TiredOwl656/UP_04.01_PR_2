import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';

class ApiAuditRepository {
  final Dio _dio;
  ApiAuditRepository(this._dio);

  Future<List<Map<String, dynamic>>> all() => guard(() async {
        final r = await _dio.get('/audit');
        return ((r.data as Map)['items'] as List)
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList();
      });
}