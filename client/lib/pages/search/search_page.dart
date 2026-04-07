import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/drama.dart';
import '../../services/analytics_service.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

/// 搜索页 - 实时搜索 + 结果列表
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Drama> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value.trim()));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.dio.get(
        '/api/v1/drama/search',
        queryParameters: {'q': q, 'limit': 20},
      );
      final envelope = res.data as Map<String, dynamic>;
      final list = ((envelope['data'] as List?) ?? [])
          .map((e) => Drama.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _results = list;
        _loading = false;
        _searched = true;
      });
    } catch (e) {
      debugPrint('[SearchPage] error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchField(),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: _onChanged,
        style: AppTextStyles.body,
        decoration: const InputDecoration(
          hintText: '搜索剧集名、标签...',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (!_searched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('搜索你想看的短剧', style: AppTextStyles.caption),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('没有找到相关剧集', style: AppTextStyles.caption),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, i) {
        final d = _results[i];
        return ListTile(
          leading: Container(
            width: 48,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2A1B3D + (d.id * 1711) % 0x333333),
                  const Color(0xFF0F0F10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.movie_outlined, size: 20, color: AppColors.textSecondary),
          ),
          title: Text(d.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${d.tags.join(" · ")} · ${d.episodeCount}集',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {
            AnalyticsService.instance.dramaClick(d.id);
            context.push('/drama/${d.id}');
          },
        );
      },
    );
  }
}
