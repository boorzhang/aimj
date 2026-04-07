/// 播放器服务 - 断点续播 / 自动连播
///
/// TODO: 接入 shared_preferences 持久化断点
class PlayerService {
  PlayerService._();
  static final PlayerService instance = PlayerService._();

  // dramaId -> 上次观看到第几集
  final Map<int, int> _lastEpisode = {};
  // "${dramaId}_${ep}" -> 断点秒
  final Map<String, int> _resumePositions = {};

  int? lastEpisodeOf(int dramaId) => _lastEpisode[dramaId];

  void recordEpisode(int dramaId, int ep) {
    _lastEpisode[dramaId] = ep;
  }

  int resumePosition(int dramaId, int ep) {
    return _resumePositions['${dramaId}_$ep'] ?? 0;
  }

  void saveResumePosition(int dramaId, int ep, int seconds) {
    _resumePositions['${dramaId}_$ep'] = seconds;
  }
}
