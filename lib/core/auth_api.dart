import 'package:dio/dio.dart';

import '../models/app_user.dart';
import 'api_exceptions.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<AuthResult> login(String username, String password) => guard(() async {
        final r = await _dio.post('/auth/login',
            data: {'username': username, 'password': password});
        return _parse(r.data as Map<String, dynamic>);
      });

  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
  }) =>
      guard(() async {
        final r = await _dio.post('/auth/register', data: {
          'username': username,
          'password': password,
          'fullName': fullName,
        });
        return _parse(r.data as Map<String, dynamic>);
      });

  Future<AuthResult> refresh(String refreshToken) => guard(() async {
        final r = await _dio
            .post('/auth/refresh', data: {'refreshToken': refreshToken});
        return _parse(r.data as Map<String, dynamic>);
      });

  Future<AppUser> me() => guard(() async {
        final r = await _dio.get('/auth/me');
        return AppUser.fromJson((r.data as Map).cast<String, dynamic>());
      });

  Future<void> logout() => guard(() => _dio.post('/auth/logout'));

  AuthResult _parse(Map<String, dynamic> d) => AuthResult(
        accessToken: d['accessToken'] as String,
        refreshToken: d['refreshToken'] as String,
        user: AppUser.fromJson((d['user'] as Map).cast<String, dynamic>()),
      );
}