import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../models/drama.dart';
import '../../models/episode.dart';
import '../../services/ads/ad_service.dart';
import '../../services/ads/mock_ad_service.dart';
import '../../services/ads/reward_strategy.dart';
import '../../services/analytics_service.dart';
import '../../services/drama_service.dart';
import '../../services/player_service.dart';
import '../../services/storage/local_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/episode_selector.dart';
import '../../widgets/reward_dialog.dart';

/// 播放页 - 9:16 沉浸式短剧播放
///
/// 核心能力（docs §3.3）：
/// - 自动下一集（片尾 3 秒倒计时可取消）
/// - 点击切换播放/暂停
/// - 底部进度条 + 时间文字
/// - 断点续播
/// - 每 3 集插屏广告
/// - 锁集激励解锁
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.dramaId, required this.episode});

  final int dramaId;
  final int episode;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _dramaService = DramaService();
  final AdService _ad = MockAdService();
  final _pacing = InterstitialPacing();
  late final RewardUnlockManager _unlock = RewardUnlockManager(_ad);

  VideoPlayerController? _controller;
  Episode? _episode;
  Drama? _drama; // 用于历史记录 + 选集抽屉
  int _currentEp = 1;
  int _episodesWatchedInSession = 0;
  bool _loading = true;

  // 片尾倒计时
  Timer? _countdownTimer;
  int? _countdownSeconds;
  bool _transitioning = false;

  // 节流保存断点
  int _lastSavedSec = -1;

  @override
  void initState() {
    super.initState();
    _currentEp = widget.episode;
    _loadAndPlay(_currentEp);
  }

  Future<void> _loadAndPlay(int ep) async {
    setState(() {
      _loading = true;
      _countdownSeconds = null;
      _transitioning = false;
    });

    // 首次进入时懒加载剧集详情，用于历史 + 选集抽屉
    try {
      _drama ??= await _dramaService.getDetail(widget.dramaId);
    } catch (e) {
      debugPrint('[Player] getDetail error: $e');
    }

    final episode = await _dramaService.getEpisode(widget.dramaId, ep);

    if (episode.locked || episode.needAdUnlock) {
      if (!mounted) return;
      final wantUnlock = await RewardDialog.show(context, unlockCount: 3);
      if (!wantUnlock) {
        if (mounted) context.pop();
        return;
      }
      final result = await _unlock.unlockEpisodes();
      if (!result.success) {
        if (mounted) context.pop();
        return;
      }
      AnalyticsService.instance.unlockSuccess(widget.dramaId, ep);
    }

    // 释放旧播放器
    await _controller?.dispose();
    final controller = VideoPlayerController.networkUrl(Uri.parse(episode.videoUrl));
    await controller.initialize();
    controller.addListener(_onTick);
    await controller.play();

    // 断点续播
    final resume = PlayerService.instance.resumePosition(widget.dramaId, ep);
    if (resume > 0) {
      await controller.seekTo(Duration(seconds: resume));
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    AnalyticsService.instance.episodePlay(widget.dramaId, ep);
    PlayerService.instance.recordEpisode(widget.dramaId, ep);

    // 写入本地观看历史
    final drama = _drama;
    if (drama != null) {
      await LocalStore.instance.recordWatch(drama, ep);
    }

    setState(() {
      _episode = episode;
      _controller = controller;
      _currentEp = ep;
      _loading = false;
      _lastSavedSec = -1;
    });
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized || !mounted) return;
    if (_transitioning) return;

    final pos = c.value.position;
    final dur = c.value.duration;
    if (dur <= Duration.zero) return;

    // 节流保存断点（按秒）
    final sec = pos.inSeconds;
    if (sec != _lastSavedSec) {
      _lastSavedSec = sec;
      PlayerService.instance.saveResumePosition(widget.dramaId, _currentEp, sec);
    }

    // 片尾 3 秒触发倒计时
    final remaining = dur - pos;
    if (_countdownSeconds == null &&
        c.value.isPlaying &&
        remaining.inMilliseconds > 0 &&
        remaining.inMilliseconds <= 3000) {
      _startCountdown();
    }

    // 播放完成 → 自动下一集
    if (pos >= dur) {
      _transitioning = true;
      _countdownTimer?.cancel();
      c.removeListener(_onTick);
      AnalyticsService.instance.episodeComplete(widget.dramaId, _currentEp);
      _goNextEpisode();
    }
  }

  void _startCountdown() {
    _countdownSeconds = 3;
    if (mounted) setState(() {});
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdownSeconds != null && _countdownSeconds! > 1) {
          _countdownSeconds = _countdownSeconds! - 1;
        } else {
          _countdownSeconds = null;
          t.cancel();
        }
      });
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    if (_countdownSeconds != null) {
      setState(() => _countdownSeconds = null);
    }
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null) return;
    _cancelCountdown();
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  Future<void> _openEpisodeSheet() async {
    final drama = _drama;
    if (drama == null || drama.episodes.isEmpty) return;
    _controller?.pause();
    _cancelCountdown();

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('选集',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: EpisodeSelector(
                      episodes: drama.episodes,
                      currentEpisode: _currentEp,
                      onSelect: (ep) => Navigator.pop(ctx, ep),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null && picked != _currentEp) {
      _transitioning = true;
      _controller?.removeListener(_onTick);
      await _loadAndPlay(picked);
    } else {
      _controller?.play();
    }
  }

  Future<void> _goNextEpisode() async {
    _episodesWatchedInSession++;

    // 每 3 集插屏
    if (_pacing.shouldShow(_episodesWatchedInSession)) {
      await _ad.showInterstitialAd(AdScene.interstitialAfterEp3);
      AnalyticsService.instance.adInterstitialShow(AdScene.interstitialAfterEp3);
      _pacing.markShown();
    }

    final next = _episode?.nextEpisode ?? (_currentEp + 1);
    AnalyticsService.instance.autoNext(widget.dramaId, next);
    await _loadAndPlay(next);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 视频层 + 点击切换播放
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlayPause,
                child: _buildVideoLayer(),
              ),
            ),

            // 顶部栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),

            // 片尾倒计时浮层
            if (_countdownSeconds != null) _buildCountdownOverlay(),

            // 播放暂停浮层（暂停时显示中央播放图标）
            if (_controller != null && !_controller!.value.isPlaying && !_loading)
              _buildPausedIndicator(),

            // 底部：进度条 + 操作行
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProgressBar(),
                  const SizedBox(height: 10),
                  _buildBottomActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_loading || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final c = _controller!;
    if (!c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    // 全屏铺满（FittedBox.cover），模拟短剧 9:16 沉浸式体验
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      ),
    );
  }

  Widget _buildPausedIndicator() {
    return const Center(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 56),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '下一集',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_countdownSeconds}s',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '点击画面取消',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox(height: 24);
    }
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: c,
      builder: (context, value, _) {
        final pos = value.position;
        final dur = value.duration;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 16,
                child: VideoProgressIndicator(
                  c,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmtDuration(pos),
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                  Text(_fmtDuration(dur),
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black54, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              '第 $_currentEp 集',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.skip_next,
            label: '下一集',
            onTap: () {
              _cancelCountdown();
              _transitioning = true;
              _controller?.removeListener(_onTick);
              _goNextEpisode();
            },
            highlight: true,
          ),
          _ActionButton(
            icon: Icons.list,
            label: '选集',
            onTap: _openEpisodeSheet,
          ),
          _ActionButton(
            icon: Icons.comment_outlined,
            label: '评论',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: '分享',
            onTap: () {
              AnalyticsService.instance.shareDrama(widget.dramaId);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: highlight ? AppColors.primary : Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
