import 'dart:async';
import 'dart:developer' as developer;

import 'ad_service.dart';

/// Mock 广告实现 - 开发联调阶段使用。
///
/// TODO: 生产环境替换为 CsjAdapter / GdtAdapter / KsAdapter + Mediation。
class MockAdService implements AdService {
  @override
  Future<void> showSplashAd() async {
    developer.log('[MockAd] showSplashAd', name: 'ad');
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> showInterstitialAd(String scene) async {
    developer.log('[MockAd] showInterstitialAd scene=$scene', name: 'ad');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> showRewardVideo(String scene) async {
    developer.log('[MockAd] showRewardVideo scene=$scene', name: 'ad');
    await Future.delayed(const Duration(seconds: 2));
    return true; // Mock 默认完整观看
  }

  @override
  Future<void> loadFeedAd(int position) async {
    developer.log('[MockAd] loadFeedAd pos=$position', name: 'ad');
  }
}
