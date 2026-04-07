/// 广告服务抽象层
///
/// 业务层不直接依赖任何广告联盟 SDK（穿山甲/优量汇/快手/AdMob），
/// 统一通过 [AdService] 调用，便于切换和聚合瀑布流。
///
/// 对应 docs/研发联调级文档API级别.md §15。
abstract class AdService {
  /// 开屏广告 - 每日首次冷启动触发
  Future<void> showSplashAd();

  /// 插屏广告 - 每 3 集后触发
  /// [scene] 场景 id：如 "after_episode_3"
  Future<void> showInterstitialAd(String scene);

  /// 激励视频 - 解锁剧集 / 去广告 / 领金币
  /// 返回 true 表示用户完整看完并应发放奖励
  Future<bool> showRewardVideo(String scene);

  /// 预加载信息流广告（Feed 第 4 位）
  Future<void> loadFeedAd(int position);
}

/// 广告场景常量
class AdScene {
  const AdScene._();

  static const String splashColdStart = 'splash_cold_start';
  static const String interstitialAfterEp3 = 'interstitial_after_ep3';
  static const String interstitialAfterEp6 = 'interstitial_after_ep6';
  static const String interstitialSwitchDrama = 'interstitial_switch_drama';

  static const String rewardUnlockEpisodes = 'reward_unlock_episodes';
  static const String rewardAdFree30Min = 'reward_ad_free_30min';
  static const String rewardCoinTask = 'reward_coin_task';
  static const String rewardEndingPreview = 'reward_ending_preview';

  static const String feedHome = 'feed_home';
}
