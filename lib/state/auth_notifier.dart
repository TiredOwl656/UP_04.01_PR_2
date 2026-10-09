import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../models/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kSessionStarted = 'auth_session_started';

  static const _maxSession = Duration(hours: 2);

  final SharedPreferences _prefs;
  final AuthApi _api;

  AuthNotifier(this._prefs, this._api);

  AppUser? _user;
  String? _accessToken;
  Timer? _sessionTimer;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null;

  bool get canBrowseCatalog => _user != null;
  bool get canPlaceOrder => _user?.role == Role.customer;
  bool get canViewOwnOrders => _user?.role == Role.customer;
  bool get canUseLoyalty => _user?.role == Role.customer;

  bool get canProcessOrders => _user?.role == Role.manager;
  bool get canViewAllOrders => _user?.role == Role.manager;
  bool get canModerateReviews => _user?.role == Role.manager;

  bool get canManageCatalog => _user?.role == Role.admin;
  bool get canManageUsers => _user?.role == Role.admin;
  bool get canViewAudit => _user?.role == Role.admin;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> restore() async {
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);
    if (access == null) return;

    final startedAt = _prefs.getInt(_kSessionStarted);
    if (startedAt != null) {
      final elapsed = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(startedAt));
      if (elapsed >= _maxSession) {
        await logout();
        return;
      }
      _startSessionTimer(remaining: _maxSession - elapsed);
    }

    _accessToken = access;
    final dump = _prefs.getString('auth_user_dump');
    if (dump != null) {
      _user = AppUser.fromJson(jsonDecode(dump) as Map<String, dynamic>);
      notifyListeners();
    }
    try {
      _user = await _api.me();
    } on UnauthorizedException {
      if (refresh != null) {
        try {
          await refreshTokens();
        } catch (_) {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (_) {
      // сервер недоступен — оставляем сессию, покажем ошибку позже
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final r = await _api.login(username, password);
    await _applyAuth(r);
  }

  Future<void> register({
    required String username,
    required String password,
    required String fullName,
  }) async {
    final r = await _api.register(
      username: username,
      password: password,
      fullName: fullName,
    );
    await _applyAuth(r);
  }

  Future<void> refreshTokens() async {
    final refresh = _prefs.getString(_kRefresh);
    if (refresh == null) throw const UnauthorizedException();
    final r = await _api.refresh(refresh);
    _accessToken = r.accessToken;
    _user = r.user;
    await _prefs.setString(_kAccess, r.accessToken);
    await _prefs.setString(_kRefresh, r.refreshToken);
    notifyListeners();
  }

  Future<void> logout() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    try {
      await _api.logout();
    } catch (_) {}
    _user = null;
    _accessToken = null;
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kSessionStarted);
    notifyListeners();
  }

  Future<void> _applyAuth(AuthResult r) async {
    _accessToken = r.accessToken;
    _user = r.user;
    await _prefs.setString(_kAccess, r.accessToken);
    await _prefs.setString(_kRefresh, r.refreshToken);
    await _prefs.setString('auth_user_dump', jsonEncode(r.user.toJson()));
    await _prefs.setInt(
      _kSessionStarted,
      DateTime.now().millisecondsSinceEpoch,
    );
    _startSessionTimer();
    notifyListeners();
  }

  void _startSessionTimer({Duration? remaining}) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(remaining ?? _maxSession, () {
      logout();
    });
  }
}