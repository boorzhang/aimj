import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth/auth_service.dart';
import '../../theme/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _items = <_MenuItem>[
    _MenuItem(icon: Icons.history, label: '观看历史', route: '/history'),
    _MenuItem(icon: Icons.favorite_border, label: '我的收藏', route: '/favorites'),
    _MenuItem(icon: Icons.download_outlined, label: '下载缓存'),
    _MenuItem(icon: Icons.monetization_on_outlined, label: '我的金币'),
    _MenuItem(icon: Icons.workspace_premium_outlined, label: '免广告会员'),
    _MenuItem(icon: Icons.settings_outlined, label: '系统设置'),
    _MenuItem(icon: Icons.privacy_tip_outlined, label: '隐私协议'),
    _MenuItem(icon: Icons.article_outlined, label: '用户协议'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: auth.loggedIn ? AppColors.primary.withValues(alpha: 0.2) : AppColors.card,
                  child: Icon(
                    auth.loggedIn ? Icons.person : Icons.person_outline,
                    size: 40,
                    color: auth.loggedIn ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.loggedIn ? (user?.nickname ?? '用户') : '未登录',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (auth.loggedIn && user != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${user.coins} 金币',
                        style: const TextStyle(color: AppColors.accent, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                if (!auth.loggedIn)
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('点击登录', style: TextStyle(color: AppColors.primary)),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                    },
                    child: const Text('退出登录', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map((item) {
            return ListTile(
              leading: Icon(item.icon, color: AppColors.textPrimary),
              title: Text(item.label, style: AppTextStyles.body),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: item.route == null ? () {} : () => context.push(item.route!),
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? route;

  const _MenuItem({required this.icon, required this.label, this.route});
}
