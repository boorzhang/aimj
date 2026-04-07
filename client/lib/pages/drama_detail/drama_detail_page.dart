import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/drama.dart';
import '../../services/drama_service.dart';
import '../../services/storage/local_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/episode_selector.dart';

class DramaDetailPage extends StatefulWidget {
  const DramaDetailPage({super.key, required this.dramaId});

  final int dramaId;

  @override
  State<DramaDetailPage> createState() => _DramaDetailPageState();
}

class _DramaDetailPageState extends State<DramaDetailPage> {
  final _service = DramaService();
  Drama? _drama;
  bool _favorited = false;

  @override
  void initState() {
    super.initState();
    _favorited = LocalStore.instance.isFavorite(widget.dramaId);
    _load();
  }

  Future<void> _load() async {
    final d = await _service.getDetail(widget.dramaId);
    if (!mounted) return;
    setState(() => _drama = d);
  }

  Future<void> _toggleFavorite() async {
    final d = _drama;
    if (d == null) return;
    await LocalStore.instance.toggleFavorite(d);
    if (!mounted) return;
    setState(() => _favorited = LocalStore.instance.isFavorite(d.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 1),
        content: Text(
          _favorited ? '已加入收藏' : '已取消收藏',
          style: AppTextStyles.body,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drama = _drama;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: drama == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(drama.title, style: const TextStyle(fontSize: 16)),
                    background: _buildCoverHeader(drama),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _favorited ? Icons.favorite : Icons.favorite_border,
                        color: _favorited ? AppColors.primary : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                  ],
                ),
                SliverToBoxAdapter(child: _buildInfo(drama)),
                SliverToBoxAdapter(child: _buildCtaRow(context, drama)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('选集',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                  ),
                ),
                SliverToBoxAdapter(
                  child: EpisodeSelector(
                    episodes: drama.episodes,
                    currentEpisode: 1,
                    onSelect: (ep) => context.push('/player/${drama.id}/$ep'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  Widget _buildCoverHeader(Drama drama) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A1E5C), Color(0xFF0F0F10)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(Icons.movie_filter, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildInfo(Drama drama) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(drama.title, style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: drama.tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(t, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '共 ${drama.episodeCount} 集 · 更新至 ${drama.updatedTo} 集 · 热度 ${drama.heat}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Text(drama.description, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildCtaRow(BuildContext context, Drama drama) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/player/${drama.id}/1'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('立即播放'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.rewardGradient,
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.card_giftcard, color: Colors.black),
                label: const Text('看广告解锁全集', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
