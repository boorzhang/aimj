import 'dart:developer' as developer;

/// 数据埋点服务 - 对应 docs §7 埋点表
///
/// TODO: 接入真实埋点 SDK（神策 / GrowingIO / 自建）
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  void track(String event, [Map<String, Object?> params = const {}]) {
    developer.log('[track] $event ${params.isEmpty ? '' : params}', name: 'analytics');
    // TODO: 上报到后端埋点网关
  }

  // --- 快捷方法 ------------------------------------------------------------

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
