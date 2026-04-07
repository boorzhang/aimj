import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// 数据埋点服务 - 对应 docs §7 埋点表
///
/// 批量上报：攒满 10 条或 5 秒定时刷一次，POST /api/v1/analytics/events
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final List<Map<String, dynamic>> _queue = [];
  Timer? _flushTimer;
  static const _batchSize = 10;
  static const _flushInterval = Duration(seconds: 5);

  void track(String event, [Map<String, Object?> params = const {}]) {
    developer.log('[track] $event ${params.isEmpty ? '' : params}', name: 'analytics');
    _queue.add({
      'event': event,
      'params': params,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    if (_queue.length >= _batchSize) {
      _flush();
    } else {
      _flushTimer ??= Timer(_flushInterval, _flush);
    }
  }

  Future<void> _flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_queue.isEmpty) return;

    final batch = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();

    try {
      await ApiClient.instance.dio.post(
        '/api/v1/analytics/events',
        data: jsonEncode({'events': batch}),
      );
    } catch (e) {
      debugPrint('[Analytics] flush error: $e');
      // 失败的放回队列头部（最多保留 100 条防爆）
      _queue.insertAll(0, batch.take(100 - _queue.length));
    }
  }

  // --- 快捷方法 ---

  void appLaunch() => track(Events.appLaunch);
  void dramaClick(int dramaId) => track(Events.dramaClick, {'drama_id': dramaId});
  void episodePlay(int dramaId, int ep) =>
      track(Events.episodePlay, {'drama_id': dramaId, 'episode': ep});
  void episodeComplete(int dramaId, int ep) =>
      track(Events.episodeComplete, {'drama_id': dramaId, 'episode': ep});
  void autoNext(int dramaId, int ep) =>
      track(Events.autoNext, {'drama_id': dramaId, 'episode': ep});
  void adInterstitialShow(String scene) =>
      track(Events.adInterstitialShow, {'scene': scene});
  void adRewardFinish(String scene) =>
      track(Events.adRewardFinish, {'scene': scene});
  void unlockSuccess(int dramaId, int ep) =>
      track(Events.unlockSuccess, {'drama_id': dramaId, 'episode': ep});
  void signIn() => track(Events.signIn);
  void shareDrama(int dramaId) => track(Events.shareDrama, {'drama_id': dramaId});
}

class Events {
  const Events._();
  static const String appLaunch = 'app_launch';
  static const String dramaClick = 'drama_click';
  static const String episodePlay = 'episode_play';
  static const String episodeComplete = 'episode_complete';
  static const String autoNext = 'auto_next';
  static const String adInterstitialShow = 'ad_interstitial_show';
  static const String adRewardFinish = 'ad_reward_finish';
  static const String unlockSuccess = 'unlock_success';
  static const String signIn = 'sign_in';
  static const String shareDrama = 'share_drama';
}
