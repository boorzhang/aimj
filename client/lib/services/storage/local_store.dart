import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/drama.dart';

/// 本地持久化存储 - SharedPreferences 单例封装
///
/// 管理：
/// - 收藏列表（LinkedHashMap 保持插入顺序）
/// - 观看历史列表（按最近时间倒序，上限 100 条）
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  static const _kFavorites = 'favorites_v1';
  static const _kHistory = 'history_v1';
  static const _historyLimit = 100;

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// 必须在 runApp 之前 await 一次
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- 收藏 ---------------------------------------------------------------

  /// 所有收藏，按收藏时间倒序（最新在前）
  List<Drama> favorites() {
    final raw = _prefs.getString(_kFavorites);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => Drama.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  bool isFavorite(int dramaId) {
    return favorites().any((d) => d.id == dramaId);
  }

  Future<void> toggleFavorite(Drama drama) async {
    final list = favorites();
    final idx = list.indexWhere((d) => d.id == drama.id);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.insert(0, _slim(drama));
    }
    await _save(_kFavorites, list);
  }

  // --- 观看历史 ------------------------------------------------------------

  /// 所有历史，按 lastWatchedAt 倒序
  List<HistoryEntry> history() {
    final raw = _prefs.getString(_kHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 记录一次观看 - 同剧集存在则更新时间 + 集数并移到最前
  Future<void> recordWatch(Drama drama, int episode) async {
    final list = history();
    list.removeWhere((h) => h.drama.id == drama.id);
    list.insert(
      0,
      HistoryEntry(
        drama: _slim(drama),
        lastEpisode: episode,
        lastWatchedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (list.length > _historyLimit) {
      list.removeRange(_historyLimit, list.length);
    }
    await _prefs.setString(
      _kHistory,
      json.encode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearHistory() => _prefs.remove(_kHistory);

  // --- 内部工具 ------------------------------------------------------------

  /// 去掉 episodes 等重字段，只保留列表展示需要的
  Drama _slim(Drama d) => Drama(
        id: d.id,
        title: d.title,
        cover: d.cover,
        description: d.description,
        tags: d.tags,
        category: d.category,
        episodeCount: d.episodeCount,
        updatedTo: d.updatedTo,
        heat: d.heat,
      );

  Future<void> _save(String key, List<Drama> list) {
    return _prefs.setString(
      key,
      json.encode(list.map((e) => e.toJson()).toList()),
    );
  }
}

/// 历史记录条目
class HistoryEntry {
  final Drama drama;
  final int lastEpisode;
  final int lastWatchedAt; // ms since epoch

  const HistoryEntry({
    required this.drama,
    required this.lastEpisode,
    required this.lastWatchedAt,
  });

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(lastWatchedAt);

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      drama: Drama.fromJson(json['drama'] as Map<String, dynamic>),
      lastEpisode: json['lastEpisode'] as int? ?? 1,
      lastWatchedAt: json['lastWatchedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'drama': drama.toJson(),
        'lastEpisode': lastEpisode,
        'lastWatchedAt': lastWatchedAt,
      };
}
