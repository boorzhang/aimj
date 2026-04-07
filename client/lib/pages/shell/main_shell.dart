import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

/// 底部 5 Tab 外壳。
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_TabItem>[
    _TabItem(path: '/home', icon: Icons.home_outlined, activeIcon: Icons.home, label: '首页'),
    _TabItem(path: '/category', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: '分类'),
    _TabItem(path: '/task', icon: Icons.card_giftcard_outlined, activeIcon: Icons.card_giftcard, label: '任务'),
    _TabItem(path: '/favorites', icon: Icons.favorite_border, activeIcon: Icons.favorite, label: '收藏'),
    _TabItem(path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: '我的'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: current,
          onTap: (i) => context.go(_tabs[i].path),
          items: [
            for (final t in _tabs)
              BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
