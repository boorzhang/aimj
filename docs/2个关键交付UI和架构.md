# AI短剧 APP MVP 产品PRD（可直接交付开发）

> 对标红果短剧，核心模式：**自产AI短剧内容 + 广告变现 + 激励解锁 + 连载追更**
>
> 目标：**30天上线 MVP，90天验证广告ROI**

---

# 一、项目目标

## 1.1 商业目标

- 通过开屏、插屏、激励视频、信息流广告实现广告ARPU
- 提升人均观看集数与DAU停留时长
- 验证内容供给（30天90集）是否可稳定支撑留存

## 1.2 核心KPI

- 次留 ≥ 35%
- 7留 ≥ 15%
- 人均观看 ≥ 18集
- 人均停留 ≥ 32分钟
- 广告ARPU ≥ ¥1/DAU

---

# 二、信息架构（IA）

底部5 Tab：

1. 首页
2. 分类
3. 任务
4. 收藏
5. 我的

---

# 三、页面PRD（线框级）

# 3.1 首页

## 页面目标

提高点击率、开剧率、首日完播率。

## 页面线框

```text
┌─────────────────────┐
│ Logo   搜索   签到   │
├─────────────────────┤
│ Banner爆款推荐       │
├─────────────────────┤
│ 男频 女频 悬疑 科幻  │
├─────────────────────┤
│ 剧集大卡片（封面）   │
│ 标题 + 简介 + 更新   │
├─────────────────────┤
│ 剧集大卡片           │
├──── 信息流广告位 ────┤
│ 剧集大卡片           │
└─────────────────────┘
```

## 核心交互

- 下拉刷新
- 无限下滑
- 点击进入详情页
- 长按：不感兴趣
- 双击：收藏

## 广告位

- 推荐流第4位：信息流广告
- Banner下方可插原生广告

---

# 3.2 剧集详情页

```text
┌─────────────────────┐
│ 封面 + 标题 + 收藏   │
├─────────────────────┤
│ 简介 标签 更新状态   │
├─────────────────────┤
│ 立即播放             │
│ 看广告解锁全集       │
├─────────────────────┤
│ 选集：1 2 3 4 5 ...  │
├─────────────────────┤
│ 同类推荐             │
└─────────────────────┘
```

## 功能

- 剧集介绍
- 演员/角色（可选）
- 追剧提醒
- 选集
- 同类推荐

---

# 3.3 播放页（广告收益核心）

## 页面线框

```text
┌─────────────────────┐
│ ← 返回      收藏 分享 │
├─────────────────────┤
│                     │
│      9:16播放器      │
│                     │
├─────────────────────┤
│ 上一集  下一集       │
│ 剧集列表  评论       │
├─────────────────────┤
│ 推荐短剧             │
└─────────────────────┘
```

## 自动播放逻辑

- 默认自动下一集
- 片尾3秒倒计时跳转
- 用户退出时记录断点

## 广告策略（核心）

### 插屏广告

- 每3集插1次
- 第3/6/9集后触发
- 冷却5分钟避免过密

### 激励视频

- 第10集后：看广告解锁后3集
- 大结局：看广告抢先看

---

# 3.4 任务中心

## 功能模块

- 每日签到
- 看广告得金币
- 连续追剧奖励
- 邀请好友
- 新手7天任务

## 激励策略

- 每看1条激励视频：+50金币
- 连续看剧30分钟：+100金币
- 分享剧集：+30金币

---

# 3.5 我的

- 历史观看
- 我的收藏
- 下载缓存
- 金币余额
- 免广告会员
- 系统设置
- 用户协议/隐私

---

# 四、Flutter 页面结构（开发可直接拆任务）

```text
/lib
 ├── pages
 │   ├── home_page.dart
 │   ├── category_page.dart
 │   ├── drama_detail_page.dart
 │   ├── player_page.dart
 │   ├── task_center_page.dart
 │   ├── profile_page.dart
 │
 ├── widgets
 │   ├── drama_card.dart
 │   ├── episode_selector.dart
 │   ├── ad_feed_widget.dart
 │   ├── reward_dialog.dart
 │
 ├── services
 │   ├── ad_service.dart
 │   ├── player_service.dart
 │   ├── analytics_service.dart
 │
 ├── models
 │   ├── drama.dart
 │   ├── episode.dart
 │   ├── user_task.dart
```

---

# 五、广告SDK接入点位（技术明确）

## 5.1 推荐聚合方案

- 穿山甲（主）
- 优量汇（补量）
- 快手联盟（补量）
- AdMob（海外预埋）

## 5.2 SDK封装建议

统一抽象：

```text
AdService
 ├── showSplashAd()
 ├── showInterstitialAd(scene)
 ├── showRewardVideo(scene)
 ├── loadFeedAd(position)
```

## 5.3 关键广告场景

### 开屏

- App冷启动

### 插屏

- 第3集后
- 第6集后
- 切合集时

### 激励

- 解锁3集
- 去广告30分钟
- 金币任务

---

# 六、CMS内容后台需求

## 剧集管理

- 上传封面
- 上传视频
- 标签
- 分类
- 上下架
- 连载状态
- 推荐权重

## AI内容流水线

- 剧本生成
- 分镜
- 配音
- 自动封面
- 自动拆条
- 买量素材导出

---

# 七、数据埋点表（非常关键）

| 事件名               | 触发时机     | 核心用途 |
| -------------------- | ------------ | -------- |
| app_launch           | 启动APP      | DAU      |
| drama_click          | 点击剧集     | CTR      |
| episode_play         | 开始播放     | 开播率   |
| episode_complete     | 单集播放完成 | 完播率   |
| auto_next            | 自动下一集   | 连播率   |
| ad_interstitial_show | 插屏展示     | 广告收益 |
| ad_reward_finish     | 激励完成     | 解锁转化 |
| unlock_success       | 解锁成功     | 收益漏斗 |
| sign_in              | 签到         | DAU提升  |
| share_drama          | 分享         | 裂变     |

---

# 八、30天研发排期（可直接执行）

## Week1

- UI高保真
- 首页
- 详情页
- 播放器

## Week2

- 广告SDK
- 插屏逻辑
- 激励解锁
- 登录收藏

## Week3

- 任务中心
- 金币系统
- 埋点系统
- CMS后台

## Week4

- 灰度测试
- 商店素材
- 上架审核
- 买量素材

---

# 九、人员配置建议

最小团队：

- 产品经理 ×1
- Flutter ×2
- 后端 ×1
- UI ×1
- 测试 ×1
- AI内容运营 ×2

---

# 十、下一阶段（90天）

建议下一版本增加：

- AI推荐算法V2
- VIP免广告
- 小程序分发
- 小说IP联动
- 海外多语言出海
- 社区评论弹幕

---

> 该PRD已达到可直接进入UI设计和研发排期阶段。
> 下一步建议立即进入：**高保真UI + Flutter组件库 + 广告SDK技术方案评审**。

---

# 十一、高保真UI视觉稿规范（商业级，接近红果短剧）

## 11.1 全局视觉风格

**设计关键词：** 沉浸、爽感、强转化、深色高级感

### 色彩系统

- 主色：#FF4D4F（高点击红）
- 强调色：#FFD666（金色任务奖励）
- 背景：#0F0F10
- 卡片：#1A1A1C
- 分割线：#2A2A2E
- 文字主：#FFFFFF
- 文字辅：#A0A0A8

### 字体层级

- 页面标题：32 / Bold
- 卡片标题：18 / Semibold
- 简介：14 / Regular
- 标签：12 / Medium
- CTA按钮：16 / Bold

### 圆角与阴影

- 卡片圆角：20
- 按钮圆角：16
- 弹窗圆角：24
- 阴影：低透明大半径，突出浮层层次

---

## 11.2 首页高保真布局

```text
┌──────────────────────────┐
│ Logo      搜索      签到  │
├──────────────────────────┤
│ 爆款Banner（自动轮播）    │
├──────────────────────────┤
│ 男频 女频 悬疑 科幻 都市  │
├──────────────────────────┤
│ 2列瀑布流剧集大卡         │
│ 9:16封面 + 更新到xx集     │
│ 爽点标签 + 热度值         │
├──────── 信息流广告 ───────┤
│ 猜你喜欢横滑专区          │
└──────────────────────────┘
```

### 关键视觉细节

- Banner 自动播放剧集高光片段
- 剧集封面使用强冲突人物特写
- 封面底部黑色渐变，突出标题
- 热门标签采用胶囊样式

---

## 11.3 播放页高保真布局

```text
┌──────────────────────────┐
│ ←      剧名      收藏 分享 │
├──────────────────────────┤
│                          │
│       9:16 沉浸式视频     │
│                          │
├──────────────────────────┤
│ 自动连播中 · 下一集倒计时  │
├──────────────────────────┤
│ 下一集  选集  评论  分享   │
├──────────────────────────┤
│ 同类推荐横滑             │
└──────────────────────────┘
```

### 商业化视觉重点

- 下一集按钮固定高亮
- 激励解锁按钮使用金色渐变
- 插屏广告关闭按钮弱化但合法可见

---

# 十二、Flutter核心页面代码骨架（可直接开发）

## 12.1 首页骨架（home_page.dart）

```dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildCategoryTabs()),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DramaCard(index: index),
                  childCount: 20,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(height: 56);
  Widget _buildBanner() => Container(height: 180);
  Widget _buildCategoryTabs() => Container(height: 48);
}
```

---

## 12.2 剧集卡片组件（drama_card.dart）

```dart
import 'package:flutter/material.dart';

class DramaCard extends StatelessWidget {
  final int index;
  const DramaCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(color: Colors.black26),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              '重生归来：豪门逆袭',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
```

---

## 12.3 播放页骨架（player_page.dart）

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse('https://demo.com/video.mp4'))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.value.isInitialized
          ? Stack(
              children: [
                Center(child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: VideoPlayer(controller),
                )),
                Positioned(bottom: 24, left: 16, right: 16, child: _buildBottomActions())
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Icon(Icons.skip_next, color: Colors.white),
        Icon(Icons.list, color: Colors.white),
        Icon(Icons.comment, color: Colors.white),
        Icon(Icons.share, color: Colors.white),
      ],
    );
  }
}
```

---

## 12.4 推荐开发插件

```yaml
dependencies:
    flutter_riverpod: ^2.0.0
    go_router: ^14.0.0
    cached_network_image: ^3.3.0
    video_player: ^2.8.0
    chewie: ^1.8.0
    flutter_screenutil: ^5.9.0
```

---

> 当前文档已经升级为：**可直接进入UI设计 + Flutter开发阶段的工程蓝图V2**。
> 下一步建议进入：组件库规范 + 广告SDK封装层 + CMS接口协议定义。

很好，这一步已经进入**可以正式开工研发**的阶段了。

我已经继续帮你补充好了这两个关键交付物，并直接更新进右侧 Canvas 文档：

## 已新增 ① 高保真UI视觉稿规范（商业级）

已经按 **接近红果短剧的成熟产品风格**补齐了：

- **完整视觉系统**
    - 主色 / 金币激励色 / 深色背景
    - 字体层级
    - 圆角
    - 阴影
    - 卡片层次

- **首页高保真布局**
    - Banner高光片段轮播
    - 2列瀑布流短剧卡片
    - 热门标签胶囊
    - 信息流广告位

- **播放页高保真布局**
    - 9:16沉浸式播放器
    - 自动连播倒计时
    - 下一集高亮CTA
    - 金色激励解锁按钮

这部分UI设计师已经可以直接开始用 **Figma 出高保真稿**。

---

## 已新增 ② Flutter核心页面代码骨架（可直接开发）

已经补到可直接建工程的程度，包括：

### 页面骨架

- `home_page.dart`
- `player_page.dart`

### 核心组件

- `drama_card.dart`

### 视频播放

已直接接入：

- `video_player`

### 推荐工程插件

已给出：

- `riverpod`
- `go_router`
- `cached_network_image`
- `chewie`

这意味着：

> **Flutter工程师今天就能开始搭项目结构 + 首页 + 播放页开发**

---

### 我建议你下一步优先做（最重要）

接下来最该补的是 **研发真正依赖的接口协议层**，否则前后端会开始对不上。

建议下一步我继续给你做：

> **《CMS后台接口协议 + Flutter API数据模型 + 广告SDK封装层》**

这是开发真正进入联调阶段最关键的一步。

尤其你们有 **AI批量产剧内容流水线**，CMS设计会直接影响后续效率。

如果你愿意，我下一步可以继续把这块直接补成 **研发联调级文档（API级别）**。
