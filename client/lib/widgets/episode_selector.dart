import 'package:flutter/material.dart';

import '../models/episode.dart';
import '../theme/app_theme.dart';

/// 选集网格 - 剧集详情页 / 播放页底部抽屉
class EpisodeSelector extends StatelessWidget {
  const EpisodeSelector({
    super.key,
    required this.episodes,
    required this.currentEpisode,
    required this.onSelect,
  });

  final List<Episode> episodes;
  final int currentEpisode;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: episodes.length,
      itemBuilder: (context, i) {
        final ep = episodes[i];
        final isCurrent = ep.episode == currentEpisode;
        return GestureDetector(
          onTap: () => onSelect(ep.episode),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCurrent ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${ep.episode}',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (ep.locked)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.lock, size: 12, color: AppColors.accent),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
