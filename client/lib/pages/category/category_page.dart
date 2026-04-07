import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/drama.dart';
import '../../services/analytics_service.dart';
import '../../services/feed_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/skeleton.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const _categories = <_Cat>[
    _Cat(key: '', label: '全部', icon: Icons.apps, color: AppColors.primary),
    _Cat(key: 'male', label: '男频', icon: Icons.male, color: Color(0xFF4A6CF7)),
    _Cat(key: 'female', label: '女频', icon: Icons.female, color: Color(0xFFFF6B9D)),
    _Cat(key: 'mystery', label: '悬疑', icon: Icons.psychology, color: Color(0xFF9B51E0)),
    _Cat(key: 'scifi', label: '科幻', icon: Icons.rocket_launch, color: Color(0xFF00C2A8)),
    _Cat(key: 'ancient', label: '古风', icon: Icons.park, color: Color(0xFFB8860B)),
    _Cat(key: 'urban', label: '都市', icon: Icons.location_city, color: Color(0xFF3498DB)),
    _Cat(key: 'comedy', label: '搞笑', icon: Icons.mood, color: Color(0xFFFFC107)),
    _Cat(key: 'romance', label: '甜宠', icon: Icons.favorite, color: Color(0xFFE91E63)),
  ];

  final _feedService = FeedService();
  int _selectedIndex = 0;
  List<Drama> _dramas = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cat = _categories[_selectedIndex].key;
      final result = await _feedService.getFeed(
        category: cat.isEmpty ? null : cat,
      );
      if (!mounted) return;
      setState(() {
        _dramas = result.list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[CategoryPage] load error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('分类', style: AppTextStyles.pageTitle),
            ),
          ),
          SliverToBoxAdapter(child: _buildCategoryChips()),
          if (_loading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              sliver: SliverGrid(
                gridDelegate: _gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const DramaCardSkeleton(),
                  childCount: 4,
                ),
              ),
            )
          else if (_dramas.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('暂无内容', style: AppTextStyles.caption),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              sliver: SliverGrid(
                gridDelegate: _gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, i) => DramaCard(
                    drama: _dramas[i],
                    onTap: () {
                      AnalyticsService.instance.dramaClick(_dramas[i].id);
                      context.push('/drama/${_dramas[i].id}');
                    },
                  ),
                  childCount: _dramas.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.62,
  );

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final active = i == _selectedIndex;
          return GestureDetector(
            onTap: () {
              if (i == _selectedIndex) return;
              setState(() => _selectedIndex = i);
              _load();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? cat.color : AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon,
                      size: 16,
                      color: active ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Cat {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Cat({required this.key, required this.label, required this.icon, required this.color});
}
