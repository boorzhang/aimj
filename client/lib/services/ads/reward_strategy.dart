import 'ad_service.dart';

/// 激励视频解锁策略
///
/// 核心规则（docs 3.3 / 5.3）：
/// - 前 10 集免费
/// - 第 10 集后：看广告解锁后 3 集
/// - 插屏节奏：每 3 集 1 次，冷却 5 分钟
class RewardUnlockManager {
  RewardUnlockManager(this._adService);

  final AdService _adService;

  /// 用户请求解锁后 N 集
  Future<UnlockResult> unlockEpisodes({int count = 3}) async {
    final ok = await _adService.showRewardVideo(AdScene.rewardUnlockEpisodes);
    if (!ok) {
      return const UnlockResult(success: false, unlockedCount: 0);
    }
    return UnlockResult(success: true, unlockedCount: count);
  }

  /// 解锁 30 分钟无广告
  Future<bool> unlockAdFree() {
    return _adService.showRewardVideo(AdScene.rewardAdFree30Min);
  }
}

class UnlockResult {
  final bool success;
  final int unlockedCount;

  const UnlockResult({required this.success, required this.unlockedCount});
}

/// 插屏广告节奏控制器 - 每 3 集 1 次 + 5 分钟冷却
class InterstitialPacing {
  InterstitialPacing({this.everyNEpisodes = 3, this.cooldown = const Duration(minutes: 5)});

  final int everyNEpisodes;
  final Duration cooldown;

  DateTime? _lastShown;

  bool shouldShow(int episodesWatchedInSession) {
    if (episodesWatchedInSession == 0) return false;
    if (episodesWatchedInSession % everyNEpisodes != 0) return false;
    final last = _lastShown;
    if (last != null && DateTime.now().difference(last) < cooldown) {
      return false;
    }
    return true;
  }

  void markShown() {
    _lastShown = DateTime.now();
  }
}
