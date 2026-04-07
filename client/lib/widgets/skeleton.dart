import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 呼吸式占位盒 - 骨架屏基础单元
///
/// 用法：
/// ```dart
/// const SkeletonBox(width: 120, height: 16)
/// ```
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, _) {
        // 0.4 -> 0.8 的呼吸透明度
        final t = 0.4 + _ctl.value * 0.4;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.divider.withValues(alpha: t),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// 首页剧集卡片骨架
class DramaCardSkeleton extends StatelessWidget {
  const DramaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        color: AppColors.card,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: SkeletonBox(width: 120, height: 14),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: SkeletonBox(width: 80, height: 10),
            ),
          ],
        ),
      ),
    );
  }
}
