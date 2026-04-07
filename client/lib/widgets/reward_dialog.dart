import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 激励视频解锁弹窗
///
/// 用法：
/// ```dart
/// final ok = await RewardDialog.show(context, unlockCount: 3);
/// ```
class RewardDialog extends StatelessWidget {
  const RewardDialog({
    super.key,
    required this.unlockCount,
    this.title = '观看广告解锁后续剧集',
  });

  final int unlockCount;
  final String title;

  static Future<bool> show(BuildContext context, {int unlockCount = 3}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => RewardDialog(unlockCount: unlockCount),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppColors.rewardGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.cardTitle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '观看一条激励视频，解锁后续 $unlockCount 集',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.rewardGradient,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                  child: const Text(
                    '立即观看',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('稍后再说', style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}
