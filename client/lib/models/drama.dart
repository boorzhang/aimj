import 'episode.dart';

/// 剧集模型 - 不可变
///
/// 对应接口：
/// - GET /api/v1/drama/feed      (列表元素)
/// - GET /api/v1/drama/{id}      (详情)
class Drama {
  final int id;
  final String title;
  final String cover;
  final String description;
  final List<String> tags;
  final String category; // male / female / mystery / scifi ...
  final int episodeCount;
  final int updatedTo;
  final int heat;
  final List<Episode> episodes;

  const Drama({
    required this.id,
    required this.title,
    required this.cover,
    this.description = '',
    this.tags = const [],
    this.category = '',
    required this.episodeCount,
    required this.updatedTo,
    this.heat = 0,
    this.episodes = const [],
  });

  factory Drama.fromJson(Map<String, dynamic> json) {
    return Drama(
      id: json['id'] as int,
      title: json['title'] as String,
      cover: json['cover'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? const [],
      category: json['category'] as String? ?? '',
      episodeCount: json['episodeCount'] as int? ?? 0,
      updatedTo: json['updatedTo'] as int? ?? 0,
      heat: json['heat'] as int? ?? 0,
      episodes: (json['episodes'] as List?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cover': cover,
        'description': description,
        'tags': tags,
        'category': category,
        'episodeCount': episodeCount,
        'updatedTo': updatedTo,
        'heat': heat,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  Drama copyWith({
    int? id,
    String? title,
    String? cover,
    String? description,
    List<String>? tags,
    String? category,
    int? episodeCount,
    int? updatedTo,
    int? heat,
    List<Episode>? episodes,
  }) {
    return Drama(
      id: id ?? this.id,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      episodeCount: episodeCount ?? this.episodeCount,
      updatedTo: updatedTo ?? this.updatedTo,
      heat: heat ?? this.heat,
      episodes: episodes ?? this.episodes,
    );
  }
}
