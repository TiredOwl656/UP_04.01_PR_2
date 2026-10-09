import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../state/auth_notifier.dart';
import 'api_exceptions.dart';
import 'config.dart';

Dio buildDio(AuthNotifier? Function() authProvider) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['__delay'] = 5000;
        final auth = authProvider.call();
        if (auth != null) {
          final token = auth.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        if (kDebugMode) {
          debugPrint('[API] -> ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
              '[API] <- ${response.statusCode} ${response.requestOptions.uri}');
        }
        final status = response.statusCode ?? 0;
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final auth = authProvider.call();
        final path = error.requestOptions.path;

        if (status == 401 &&
            auth != null &&
            auth.isAuthenticated &&
            !path.contains('/auth/')) {
          try {
            await auth.refreshTokens();
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${auth.accessToken}';
            final clone = await dio.fetch(opts);
            return handler.resolve(clone);
          } catch (_) {
            await auth.logout();
            return handler.reject(error);
          }
        }
        if (kDebugMode) {
          debugPrint('[API] ! $path: ${error.type}');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}