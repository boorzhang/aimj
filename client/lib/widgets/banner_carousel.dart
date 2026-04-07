import 'dart:async';

import 'package:flutter/material.dart';

import '../models/drama.dart';
import '../theme/app_theme.dart';

/// 首页 Banner 轮播 - 展示热门剧集
///
/// 自动 4 秒切换，手动滑动后重置计时。
/// 底部圆点指示器 + 渐变遮罩上叠标题/标签。
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.dramas,
    required this.onTap,
  });

  final List<Drama> dramas;
  final ValueChanged<Drama> onTap;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageCtl;
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtl = PageController();
    _startAuto();
  }

  void _startAuto() {
    _autoTimer?.cancel();
    if (widget.dramas.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.dramas.length;
      _pageCtl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dramas.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtl,
            itemCount: widget.dramas.length,
            onPageChanged: (i) {
              setState(() => _current = i);
              _startAuto(); // 手动滑后重置计时
            },
            itemBuilder: (context, i) => _buildSlide(widget.dramas[i]),
          ),
          // 圆点指示器
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.dramas.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _current ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _current ? AppColors.primary : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Drama drama) {
    return GestureDetector(
      onTap: () => widget.onTap(drama),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(
            colors: [
              Color(0xFF2A1B3D + (drama.id * 1711) % 0x333333),
              const Color(0xFF0F0F10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面占位（有 cover 时替换为 CachedNetworkImage）
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: const Center(
                child: Icon(Icons.movie_filter, size: 48, color: Colors.white12),
              ),
            ),
            // 底部渐变遮罩
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1.0],
                  ),
                ),
              ),
            ),
            // 文字信息
            Positioned(
              left: 16,
              right: 16,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drama.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('热播',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      ...drama.tags.take(2).map((t) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(t,
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          )),
                      const Spacer(),
                      Text(
                        '更新至${drama.updatedTo}集',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
