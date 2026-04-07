import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/drama.dart';
import '../../services/analytics_service.dart';
import '../../services/feed_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_feed_widget.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _feedService = FeedService();
  final _scrollCtl = ScrollController();
  final List<Drama> _dramas = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  static const _categories = ['推荐', '男频', '女频', '悬疑', '科幻', '都市', '古风', '搞笑'];
  int _categoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtl.addListener(_onScroll);
    AnalyticsService.instance.appLaunch();
  }

  @override
  void dispose() {
    _scrollCtl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    final max = _scrollCtl.position.maxScrollExtent;
    final current = _scrollCtl.position.pixels;
    if (current >= max - 300) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _page = 1;
    });
    try {
      final result = await _feedService.getFeed(page: 1);
      if (!mounted) return;
      setState(() {
        _dramas
          ..clear()
          ..addAll(result.list);
        _hasMore = result.hasMore;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[HomePage] feed error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final result = await _feedService.getFeed(page: nextPage);
      if (!mounted) return;
      setState(() {
        _dramas.addAll(result.list);
        _page = nextPage;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (e) {
      debugPrint('[HomePage] loadMore error: $e');
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          controller: _scrollCtl,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: _dramas.isEmpty
                  ? _buildBannerPlaceholder()
                  : BannerCarousel(
                      dramas: _dramas.take(4).toList(),
                      onTap: (d) {
                        AnalyticsService.instance.dramaClick(d.id);
                        context.push('/drama/${d.id}');
                      },
                    ),
            ),
            SliverToBoxAdapter(child: _buildCategoryTabs()),
            if (_loading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const DramaCardSkeleton(),
                    childCount: 6,
                  ),
                ),
              )
            else ...[
              // 前 4 部：2 列瀑布流
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    _buildDramaTile,
                    childCount: _dramas.length >= 4 ? 4 : _dramas.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
              // 信息流广告位（整行）
              const SliverToBoxAdapter(child: AdFeedWidget()),
              // 剩余剧集
              if (_dramas.length > 4)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildDramaTile(context, i + 4),
                      childCount: _dramas.length - 4,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                  ),
                ),
              // 加载更多指示器
              if (_loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                ),
              if (!_hasMore && _dramas.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('没有更多了', style: AppTextStyles.caption)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDramaTile(BuildContext context, int index) {
    if (index >= _dramas.length) return const SizedBox.shrink();
    final drama = _dramas[index];
    return DramaCard(
      drama: drama,
      onTap: () {
        AnalyticsService.instance.dramaClick(drama.id);
        context.push('/drama/${drama.id}');
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text('AI短剧',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: AppColors.accent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1E5C), Color(0xFFFF4D4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AI短剧',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 6),
            Text('每日更新 · 追剧爽到飞起',
                style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == _categoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _categoryIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
