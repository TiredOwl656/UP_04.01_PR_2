import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/loyalty_card.dart';

class ApiLoyaltyRepository {
  final Dio _dio;
  ApiLoyaltyRepository(this._dio);

  Future<LoyaltyCard?> myCard() => guard(() async {
        final r = await _dio.get('/loyalty/my');
        if (r.data == null) return null;
        return LoyaltyCard.fromJson((r.data as Map).cast<String, dynamic>());
      });
}