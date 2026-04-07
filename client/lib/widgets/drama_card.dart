import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/drama.dart';
import '../theme/app_theme.dart';

/// 剧集卡片 - 首页瀑布流 / 同类推荐使用
class DramaCard extends StatelessWidget {
  const DramaCard({super.key, required this.drama, this.onTap});

  final Drama drama;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          color: AppColors.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCover()),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Text(
                  drama.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    _Tag(text: '更新${drama.updatedTo}/${drama.episodeCount}'),
                    const SizedBox(width: 6),
                    if (drama.tags.isNotEmpty)
                      Expanded(
                        child: Text(
                          drama.tags.take(2).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (drama.cover.isEmpty)
          // Mock 阶段占位 - 根据 id 生成渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2A1B3D + (drama.id * 1711) % 0x333333),
                  const Color(0xFF0F0F10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.movie_outlined, color: AppColors.textSecondary, size: 40),
            ),
          )
        else
          CachedNetworkImage(
            imageUrl: drama.cover,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black26),
            errorWidget: (_, __, ___) => Container(color: Colors.black26),
          ),
        // 底部渐变突出标题
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
              ),
            ),
          ),
        ),
        // 右上角热度
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, size: 12, color: AppColors.primary),
                const SizedBox(width: 2),
                Text(
                  _formatHeat(drama.heat),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatHeat(int heat) {
    if (heat >= 10000) return '${(heat / 10000).toStringAsFixed(1)}w';
    return '$heat';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.primary),
      ),
    );
  }
}
