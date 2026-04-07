import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/drama.dart';
import '../theme/app_theme.dart';

/// 分享海报生成器
///
/// 用法：
/// ```dart
/// final bytes = await SharePoster.generate(context, drama, episode: 5);
/// // bytes 是 PNG Uint8List，可保存或分享
/// ```
class SharePoster {
  SharePoster._();

  /// 生成海报 PNG 字节
  static Future<Uint8List?> generate(
    BuildContext context,
    Drama drama, {
    int? episode,
  }) async {
    final key = GlobalKey();
    final overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999, // 渲染在屏幕外
        child: RepaintBoundary(
          key: key,
          child: _PosterWidget(drama: drama, episode: episode),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);

    // 等一帧让 Widget 渲染完成
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      overlay.remove();
    }
  }
}

/// 海报 Widget - 390x694 竖屏海报
class _PosterWidget extends StatelessWidget {
  const _PosterWidget({required this.drama, this.episode});

  final Drama drama;
  final int? episode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 694,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2A1B3D + (drama.id * 1711) % 0x333333),
            const Color(0xFF0F0F10),
            const Color(0xFF0F0F10),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 顶部大图区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A1B3D + (drama.id * 1711) % 0x333333),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Icon(Icons.movie_filter, size: 100, color: Colors.white12),
              ),
            ),
          ),

          // 内容区域
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  drama.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // 标签
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: drama.tags.take(4).map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(t,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          )),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 集数信息
                Text(
                  episode != null
                      ? '正在看第 $episode 集 · 共 ${drama.episodeCount} 集'
                      : '共 ${drama.episodeCount} 集 · 更新至 ${drama.updatedTo} 集',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),

                if (drama.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    drama.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 底部：Logo + 二维码占位
                Row(
                  children: [
                    // Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI短剧',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              )),
                          Text('扫码下载 APP 追剧',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      ),
                    ),
                    // 二维码占位
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.qr_code_2, size: 48, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 热度角标
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, size: 14, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    drama.heat >= 10000
                        ? '${(drama.heat / 10000).toStringAsFixed(1)}w'
                        : '${drama.heat}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 分享 Sheet - 展示海报预览 + 保存按钮
class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.drama, this.episode});

  final Drama drama;
  final int? episode;

  static Future<void> show(BuildContext context, Drama drama, {int? episode}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareSheet(drama: drama, episode: episode),
    );
  }

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  Uint8List? _posterBytes;
  bool _generating = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    // 延迟确保 overlay 可用
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final bytes = await SharePoster.generate(
      context,
      widget.drama,
      episode: widget.episode,
    );
    if (!mounted) return;
    setState(() {
      _posterBytes = bytes;
      _generating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text('分享海报',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),

          // 海报预览
          Expanded(
            child: _generating
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _posterBytes == null
                    ? const Center(child: Text('生成失败', style: AppTextStyles.caption))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_posterBytes!, fit: BoxFit.contain),
                      ),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _posterBytes == null
                      ? null
                      : () {
                          // TODO: 接入 image_gallery_saver 或 share_plus 保存到相册
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.card,
                              content: Text('海报已生成（保存到相册需接入平台 SDK）',
                                  style: AppTextStyles.body),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.save_alt),
                  label: const Text('保存海报'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('取消'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.divider),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
