/// 运行时环境开关。
///
/// 用法：
///   flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE=http://localhost:8080
class Env {
  const Env._();

  /// 是否走本地 mock 数据。默认 false（接真后端）。
  static const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

  /// 后端 API Base URL。默认指向本机 Go 服务。
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8090',
  );
}
