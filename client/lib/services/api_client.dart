import 'package:dio/dio.dart';

import 'env.dart';

/// 统一 API Client - Dio 封装
///
/// baseUrl 通过 --dart-define=API_BASE=... 注入，默认 http://localhost:8080
class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  static ApiClient? _instance;

  static ApiClient get instance {
    _instance ??= ApiClient._(_buildDio());
    return _instance!;
  }

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: 从本地读取 JWT 并注入
          // options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (e, handler) {
          // TODO: 统一错误上报 + 401 跳登录
          handler.next(e);
        },
      ),
    );

    return dio;
  }

  Dio get dio => _dio;
}

/// 后端统一返回 envelope: { code, message, data }
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  const ApiResponse({required this.code, required this.message, this.data});

  bool get isOk => code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) mapper,
  ) {
    return ApiResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: mapper(json['data']),
    );
  }
}
