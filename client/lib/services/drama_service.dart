import '../models/drama.dart';
import '../models/episode.dart';
import 'api_client.dart';
import 'env.dart';
import 'mock_data.dart';

/// 剧集详情 & 播放地址服务
class DramaService {
  DramaService({ApiClient? client, bool? useMock})
      : _client = client ?? ApiClient.instance,
        _useMock = useMock ?? Env.useMock;

  final ApiClient _client;
  final bool _useMock;

  Future<Drama> getDetail(int id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.dramaDetail(id);
    }
    final res = await _client.dio.get('/api/v1/drama/$id');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Drama.fromJson(data);
  }

  Future<Episode> getEpisode(int dramaId, int ep) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 150));
      return MockData.episode(dramaId, ep);
    }
    final res = await _client.dio.get('/api/v1/drama/$dramaId/episode/$ep');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Episode.fromJson(data);
  }
}
