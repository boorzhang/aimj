# AI短剧 APP · Flutter 客户端

对标红果短剧的 AI 短剧 APP MVP 客户端。详细产品/UI/API 规范见仓库根目录 `docs/`。

## 技术栈

- Flutter 3.22+ / Dart 3.3+
- 状态管理：`flutter_riverpod`
- 路由：`go_router`
- 网络：`dio`
- 播放器：`video_player` + `chewie`
- 屏幕适配：`flutter_screenutil`

## 目录结构

```
lib/
├── main.dart                 # 入口
├── app.dart                  # MaterialApp + 路由
├── theme/
│   └── app_theme.dart        # 深色主题 / 颜色常量
├── router/
│   └── app_router.dart       # go_router 配置
├── models/                   # 不可变数据模型
│   ├── drama.dart
│   ├── episode.dart
│   └── user_task.dart
├── services/                 # API / 广告 / 埋点服务
│   ├── api_client.dart
│   ├── feed_service.dart
│   ├── drama_service.dart
│   ├── player_service.dart
│   ├── analytics_service.dart
│   └── ads/
│       ├── ad_service.dart
│       ├── mock_ad_service.dart
│       └── reward_strategy.dart
├── pages/                    # 页面
│   ├── shell/main_shell.dart
│   ├── home/home_page.dart
│   ├── category/category_page.dart
│   ├── task/task_center_page.dart
│   ├── favorites/favorites_page.dart
│   ├── profile/profile_page.dart
│   ├── drama_detail/drama_detail_page.dart
│   └── player/player_page.dart
└── widgets/                  # 通用组件
    ├── drama_card.dart
    ├── episode_selector.dart
    ├── ad_feed_widget.dart
    └── reward_dialog.dart
```

## 快速开始

```bash
cd client
flutter pub get
flutter run
```

## 当前状态

- [x] 工程骨架 + 目录结构
- [x] 主题 & 路由
- [x] 数据模型
- [x] Mock Service 层
- [x] 5 Tab 页面骨架 + 详情 / 播放页
- [x] 基础通用 Widgets
- [ ] 接入真实后端 API（见 `docs/研发联调级文档API级别.md`）
- [ ] 接入真实广告 SDK（穿山甲 / 优量汇 / 快手）
- [ ] 埋点上报实现

## 设计规范（摘自 docs 11.1）

| 类型 | 色值 |
|---|---|
| 主色 | `#FF4D4F` |
| 金色奖励 | `#FFD666` |
| 背景 | `#0F0F10` |
| 卡片 | `#1A1A1C` |
| 分割线 | `#2A2A2E` |
| 主文字 | `#FFFFFF` |
| 辅文字 | `#A0A0A8` |
