import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _items = <_MenuItem>[
    _MenuItem(icon: Icons.history, label: '观看历史', route: '/history'),
    _MenuItem(icon: Icons.favorite_border, label: '我的收藏', route: '/favorites'),
    _MenuItem(icon: Icons.download_outlined, label: '下载缓存'),
    _MenuItem(icon: Icons.monetization_on_outlined, label: '我的金币'),
    _MenuItem(icon: Icons.workspace_premium_outlined, label: '免广告会员'),
    _MenuItem(icon: Icons.redeem_outlined, label: '兑换码'),
    _MenuItem(icon: Icons.settings_outlined, label: '系统设置'),
    _MenuItem(icon: Icons.privacy_tip_outlined, label: '隐私协议'),
    _MenuItem(icon: Icons.article_outlined, label: '用户协议'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.card,
                  child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text('未登录',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                TextButton(
                  onPressed: () {},
                  child: const Text('点击登录', style: TextStyle(color: AppColors.primary)),
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
