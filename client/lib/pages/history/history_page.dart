import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/storage/local_store.dart';
import '../../theme/app_theme.dart';

/// 观看历史页
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _items = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _items = LocalStore.instance.history());
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('清空观看历史？', style: TextStyle(color: Colors.white)),
        content: const Text('该操作不可撤销。', style: AppTextStyles.caption),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LocalStore.instance.clearHistory();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('观看历史'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clear,
            ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 72, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('暂无观看记录', style: AppTextStyles.caption),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, i) {
                final e = _items[i];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2A1B3D + (e.drama.id * 1711) % 0x333333),
                          const Color(0xFF0F0F10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.movie_outlined, size: 20, color: AppColors.textSecondary),
                  ),
                  title: Text(e.drama.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '观看至 ${e.lastEpisode} 集 · ${_fmtTime(e.time)}',
                    style: AppTextStyles.caption,
                  ),
                  trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                  onTap: () {
                    context.push('/player/${e.drama.id}/${e.lastEpisode}');
                  },
                );
              },
            ),
    );
  }

  static String _fmtTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${t.month}-${t.day}';
  }
}
