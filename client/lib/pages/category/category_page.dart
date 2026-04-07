import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  static const _categories = [
    ('男频', Icons.male, Color(0xFF4A6CF7)),
    ('女频', Icons.female, Color(0xFFFF6B9D)),
    ('悬疑', Icons.psychology, Color(0xFF9B51E0)),
    ('科幻', Icons.rocket_launch, Color(0xFF00C2A8)),
    ('古风', Icons.park, Color(0xFFB8860B)),
    ('都市', Icons.location_city, Color(0xFF3498DB)),
    ('搞笑', Icons.mood, Color(0xFFFFC107)),
    ('甜宠', Icons.favorite, Color(0xFFE91E63)),
  ];

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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final (name, icon, color) = _categories[i];
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.6), AppColors.card],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(icon, color: Colors.white, size: 28),
                        Text(name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
