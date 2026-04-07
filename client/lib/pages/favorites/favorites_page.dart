import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/drama.dart';
import '../../services/storage/local_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/drama_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with RouteAware {
  List<Drama> _items = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  void _reload() {
    setState(() => _items = LocalStore.instance.favorites());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('我的收藏', style: AppTextStyles.pageTitle),
            ),
          ),
          if (_items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 72, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('还没有收藏任何剧集', style: AppTextStyles.caption),
                  ],
                ),
              ),
            )
          else
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
                  (context, i) => DramaCard(
                    drama: _items[i],
                    onTap: () async {
                      await context.push('/drama/${_items[i].id}');
                      if (mounted) _reload(); // 从详情页回来刷新（可能取消收藏）
                    },
                  ),
                  childCount: _items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
