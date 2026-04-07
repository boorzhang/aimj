import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_client.dart';
import 'auth_state.dart';

/// 全局鉴权 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _kToken = 'auth_token';

  /// 启动时从本地恢复 token 并拉取用户信息
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    if (token == null || token.isEmpty) return;
    try {
      _setToken(token);
      final user = await _fetchMe();
      state = AuthState(loggedIn: true, token: token, user: user);
    } catch (e) {
      debugPrint('[Auth] restore failed: $e');
      await logout();
    }
  }

  /// 手机号+验证码登录
  Future<String?> login(String phone, String code) async {
    try {
      final res = await ApiClient.instance.dio.post(
        '/api/v1/user/login',
        data: {'phone': phone, 'code': code},
      );
      final envelope = res.data as Map<String, dynamic>;
      if (envelope['code'] != 0) {
        return envelope['message'] as String? ?? '登录失败';
      }
      final data = envelope['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);

      _setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, token);

      state = AuthState(loggedIn: true, token: token, user: user);
      return null; // 成功
    } catch (e) {
      debugPrint('[Auth] login error: $e');
      return '网络错误，请重试';
    }
  }

  /// 签到
  Future<Map<String, dynamic>?> signIn() async {
    try {
      final res = await ApiClient.instance.dio.post('/api/v1/user/sign-in');
      final envelope = res.data as Map<String, dynamic>;
      if (envelope['code'] != 0) {
        return {'error': envelope['message']};
      }
      final data = envelope['data'] as Map<String, dynamic>;
      // 更新本地金币
      final coins = data['totalCoins'] as int? ?? state.user?.coins ?? 0;
      if (state.user != null) {
        state = state.copyWith(user: state.user!.copyWith(coins: coins));
      }
      return data;
    } catch (e) {
      return {'error': '网络错误'};
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      final user = await _fetchMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    state = const AuthState();
  }

  void _setToken(String token) {
    ApiClient.instance.dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<UserProfile> _fetchMe() async {
    final res = await ApiClient.instance.dio.get('/api/v1/user/me');
    final envelope = res.data as Map<String, dynamic>;
    return UserProfile.fromJson(envelope['data'] as Map<String, dynamic>);
  }
}
