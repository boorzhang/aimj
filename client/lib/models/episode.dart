/// 分集模型 - 不可变
///
/// 对应接口：GET /api/v1/drama/{id}/episode/{ep}
class Episode {
  final int episode;
  final int duration; // 秒
  final bool locked;
  final String videoUrl;
  final int? nextEpisode;
  final bool needAdUnlock;
  final String unlockType; // reward_video / coin / vip

  const Episode({
    required this.episode,
    this.duration = 0,
    this.locked = false,
    this.videoUrl = '',
    this.nextEpisode,
    this.needAdUnlock = false,
    this.unlockType = '',
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episode: json['episode'] as int,
      duration: json['duration'] as int? ?? 0,
      locked: json['locked'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String? ?? '',
      nextEpisode: json['nextEpisode'] as int?,
      needAdUnlock: json['needAdUnlock'] as bool? ?? false,
      unlockType: json['unlockType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'episode': episode,
        'duration': duration,
        'locked': locked,
        'videoUrl': videoUrl,
        'nextEpisode': nextEpisode,
        'needAdUnlock': needAdUnlock,
        'unlockType': unlockType,
      };

  Episode copyWith({
    int? episode,
    int? duration,
    bool? locked,
    String? videoUrl,
    int? nextEpisode,
    bool? needAdUnlock,
    String? unlockType,
  }) {
    return Episode(
      episode: episode ?? this.episode,
      duration: duration ?? this.duration,
      locked: locked ?? this.locked,
      videoUrl: videoUrl ?? this.videoUrl,
      nextEpisode: nextEpisode ?? this.nextEpisode,
      needAdUnlock: needAdUnlock ?? this.needAdUnlock,
      unlockType: unlockType ?? this.unlockType,
    );
  }
}
