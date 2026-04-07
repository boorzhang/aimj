/// 任务中心任务模型 - 不可变
class UserTask {
  final String id;
  final String title;
  final String description;
  final int coinReward;
  final TaskType type;
  final int progress;
  final int target;
  final bool completed;

  const UserTask({
    required this.id,
    required this.title,
    required this.description,
    required this.coinReward,
    required this.type,
    this.progress = 0,
    this.target = 1,
    this.completed = false,
  });

  bool get isDone => progress >= target;
  double get progressRatio => target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);

  factory UserTask.fromJson(Map<String, dynamic> json) {
    return UserTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      coinReward: json['coinReward'] as int? ?? 0,
      type: TaskType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'signIn'),
        orElse: () => TaskType.signIn,
      ),
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coinReward': coinReward,
        'type': type.name,
        'progress': progress,
        'target': target,
        'completed': completed,
      };

  UserTask copyWith({
    int? progress,
    bool? completed,
  }) {
    return UserTask(
      id: id,
      title: title,
      description: description,
      coinReward: coinReward,
      type: type,
      progress: progress ?? this.progress,
      target: target,
      completed: completed ?? this.completed,
    );
  }
}

enum TaskType {
  signIn, // 签到
  watchAd, // 看广告
  watchDrama, // 看剧
  share, // 分享
  invite, // 邀请
}
