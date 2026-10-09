import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';

class ApiUserRepository {
  final Dio _dio;
  ApiUserRepository(this._dio);

  Future<List<AppUser>> all() => guard(() async {
        final r = await _dio.get('/users');
        return ((r.data as Map)['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AppUser.fromJson)
            .toList();
      });

  Future<AppUser> setRole(int id, Role role) => guard(() async {
        final r = await _dio.patch('/users/$id/role', data: {'role': role.name});
        return AppUser.fromJson((r.data as Map).cast<String, dynamic>());
      });

  Future<void> block(int id) => guard(() => _dio.post('/users/$id/block'));
}