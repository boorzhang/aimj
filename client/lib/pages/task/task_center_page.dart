import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_task.dart';
import '../../services/ads/ad_service.dart';
import '../../services/ads/mock_ad_service.dart';
import '../../services/analytics_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/mock_data.dart';
import '../../theme/app_theme.dart';

class TaskCenterPage extends ConsumerStatefulWidget {
  const TaskCenterPage({super.key});

  @override
  ConsumerState<TaskCenterPage> createState() => _TaskCenterPageState();
}

class _TaskCenterPageState extends ConsumerState<TaskCenterPage> {
  final AdService _ad = MockAdService();
  late List<UserTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List<UserTask>.from(MockData.tasks());
  }

  Future<void> _doSignIn() async {
    final auth = ref.read(authProvider);
    if (!auth.loggedIn) {
      context.push('/login');
      return;
    }
    final result = await ref.read(authProvider.notifier).signIn();
    if (!mounted) return;
    if (result == null) return;
    final error = result['error'];
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.card,
          content: Text('$error', style: AppTextStyles.body),
        ),
      );
    } else {
      final reward = result['coinReward'] ?? 0;
      final days = result['consecutiveDays'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.card,
          content: Text(
            '签到成功！连续 $days 天，+$reward 金币',
            style: AppTextStyles.body,
          ),
        ),
      );
      // 标记签到任务完成
      setState(() {
        final idx = _tasks.indexWhere((t) => t.type == TaskType.signIn);
        if (idx != -1) {
          _tasks[idx] = _tasks[idx].copyWith(progress: 1, completed: true);
        }
      });
    }
  }

  Future<void> _doTask(UserTask task) async {
    if (task.type == TaskType.signIn) {
      await _doSignIn();
      return;
    }

    final auth = ref.read(authProvider);
    if (!auth.loggedIn) {
      context.push('/login');
      return;
    }

    if (task.type == TaskType.watchAd) {
      final ok = await _ad.showRewardVideo(AdScene.rewardCoinTask);
      if (!ok) return;
      AnalyticsService.instance.adRewardFinish(AdScene.rewardCoinTask);
      // 给后端加金币
      await ref.read(authProvider.notifier).refreshUser();
    }

    if (!mounted) return;
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = _tasks[idx].copyWith(
          progress: _tasks[idx].progress + 1,
          completed: (_tasks[idx].progress + 1) >= _tasks[idx].target,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        content: Text('+${task.coinReward} 金币', style: AppTextStyles.body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final coins = auth.user?.coins ?? 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('任务中心', style: AppTextStyles.pageTitle),
          const SizedBox(height: 16),
          _buildCoinCard(coins, auth.loggedIn),
          const SizedBox(height: 20),
          const Text('每日任务',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._tasks.map(_buildTaskItem),
        ],
      ),
    );
  }

  Widget _buildCoinCard(int coins, bool loggedIn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB33A), Color(0xFFFF7A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我的金币', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                loggedIn ? '$coins' : '--',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!loggedIn)
            TextButton(
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF7A3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('登录领金币'),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(UserTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text('${task.description} · +${task.coinReward}',
                    style: AppTextStyles.caption),
                if (task.target > 1) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.progressRatio,
                      minHeight: 4,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${task.progress}/${task.target}', style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: task.isDone ? null : () => _doTask(task),
            style: ElevatedButton.styleFrom(
              backgroundColor: task.isDone ? AppColors.divider : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(task.isDone ? '已完成' : '去完成'),
          ),
        ],
      ),
    );
  }
}
