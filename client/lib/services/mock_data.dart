import '../models/drama.dart';
import '../models/episode.dart';
import '../models/user_task.dart';

/// 联调真实后端前的本地 Mock 数据源。
class MockData {
  MockData._();

  static const _titles = [
    '重生归来：豪门逆袭',
    '战神不败：都市神王',
    '赘婿崛起：复仇之路',
    '甜宠总裁的心尖宝',
    '时间循环：重回高考',
    '赛博都市：AI恋人',
    '医武双修：回到校园',
    '豪门千金归来',
    '穿越王朝：女相权谋',
    '废柴逆袭：系统降临',
    '末日觉醒：我是最强',
    '平行宇宙：另一个我',
  ];

  static const _tagPool = [
    ['重生', '逆袭'],
    ['战神', '都市'],
    ['赘婿', '复仇'],
    ['甜宠', '总裁'],
    ['科幻', '悬疑'],
    ['AI', '恋爱'],
    ['医武', '校园'],
    ['豪门', '女频'],
    ['古风', '权谋'],
    ['系统', '爽文'],
    ['末日', '觉醒'],
    ['平行', '脑洞'],
  ];

  static List<Drama> dramas() {
    return List.generate(_titles.length, (i) {
      return Drama(
        id: 1000 + i,
        title: _titles[i],
        cover: '',
        description: '${_titles[i]} - AI 生成短剧，每日更新，追更爽到飞起。',
        tags: _tagPool[i],
        category: i.isEven ? 'male' : 'female',
        episodeCount: 60,
        updatedTo: 20 + (i * 3) % 40,
        heat: 100000 + i * 87654,
      );
    });
  }

  static Drama dramaDetail(int id) {
    final base = dramas().firstWhere(
      (d) => d.id == id,
      orElse: () => dramas().first,
    );
    final episodes = List.generate(base.episodeCount, (i) {
      final ep = i + 1;
      return Episode(
        episode: ep,
        duration: 90 + (i % 5) * 10,
        locked: ep > 10, // 前 10 集免费
        needAdUnlock: ep > 10 && ep <= 30,
        unlockType: ep > 30 ? 'vip' : 'reward_video',
      );
    });
    return base.copyWith(episodes: episodes);
  }

  static Episode episode(int dramaId, int ep) {
    return Episode(
      episode: ep,
      duration: 95,
      locked: false,
      // 公开测试视频
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      nextEpisode: ep + 1,
      needAdUnlock: ep > 10 && ep % 3 == 0,
      unlockType: 'reward_video',
    );
  }

  static List<UserTask> tasks() {
    return const [
      UserTask(
        id: 'sign_in',
        title: '每日签到',
        description: '连续签到领金币',
        coinReward: 20,
        type: TaskType.signIn,
        target: 1,
      ),
      UserTask(
        id: 'watch_ad',
        title: '观看激励视频',
        description: '每看一条 +50 金币',
        coinReward: 50,
        type: TaskType.watchAd,
        progress: 2,
        target: 5,
      ),
      UserTask(
        id: 'watch_drama',
        title: '连续追剧 30 分钟',
        description: '累计观看满 30 分钟',
        coinReward: 100,
        type: TaskType.watchDrama,
        progress: 12,
        target: 30,
      ),
      UserTask(
        id: 'share',
        title: '分享剧集给好友',
        description: '每次分享 +30 金币',
        coinReward: 30,
        type: TaskType.share,
        target: 3,
      ),
      UserTask(
        id: 'invite',
        title: '邀请新用户',
        description: '邀请 1 人注册 +500 金币',
        coinReward: 500,
        type: TaskType.invite,
        target: 1,
      ),
    ];
  }
}
