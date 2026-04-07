import 'package:flutter/foundation.dart';

import '../models/drama.dart';
import 'api_client.dart';
import 'env.dart';
import 'mock_data.dart';

/// 首页推荐流服务
///
/// 接口：GET /api/v1/drama/feed?page=&pageSize=&category=
class FeedService {
  FeedService({ApiClient? client, bool? useMock})
      : _client = client ?? ApiClient.instance,
        _useMock = useMock ?? Env.useMock;

  final ApiClient _client;
  final bool _useMock;

  Future<FeedResult> getFeed({
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return FeedResult(
        list: MockData.dramas(),
        hasMore: page < 3,
      );
    }

    debugPrint('[FeedService] GET ${Env.apiBase}/api/v1/drama/feed useMock=$_useMock');
    try {
      final res = await _client.dio.get(
        '/api/v1/drama/feed',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (category != null) 'category': category,
        },
      );
      debugPrint('[FeedService] response status=${res.statusCode} type=${res.data.runtimeType}');
      final envelope = res.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      final list = ((data['list'] as List?) ?? const [])
          .map((e) => Drama.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[FeedService] parsed ${list.length} dramas');
      return FeedResult(
        list: list,
        hasMore: data['hasMore'] as bool? ?? false,
      );
    } catch (e, st) {
      debugPrint('[FeedService] ERROR: $e\n$st');
      rethrow;
    }
  }
}

class FeedResult {
  final List<Drama> list;
  final bool hasMore;

  const FeedResult({required this.list, required this.hasMore});
}
