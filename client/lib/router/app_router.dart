import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/category/category_page.dart';
import '../pages/drama_detail/drama_detail_page.dart';
import '../pages/favorites/favorites_page.dart';
import '../pages/history/history_page.dart';
import '../pages/home/home_page.dart';
import '../pages/player/player_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/shell/main_shell.dart';
import '../pages/task/task_center_page.dart';

/// 应用路由 - go_router 配置
///
/// 底部 5 Tab: 首页 / 分类 / 任务 / 收藏 / 我的
/// 详情、播放页走 push 路由覆盖 Tab。
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/category',
            name: 'category',
            builder: (_, __) => const CategoryPage(),
          ),
          GoRoute(
            path: '/task',
            name: 'task',
            builder: (_, __) => const TaskCenterPage(),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (_, __) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/drama/:id',
        name: 'drama_detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return DramaDetailPage(dramaId: id);
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (_, __) => const HistoryPage(),
      ),
      GoRoute(
        path: '/player/:id/:ep',
        name: 'player',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          final ep = int.tryParse(state.pathParameters['ep'] ?? '1') ?? 1;
          return PlayerPage(dramaId: id, episode: ep);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('路由错误: ${state.error}'),
      ),
    ),
  );
}
