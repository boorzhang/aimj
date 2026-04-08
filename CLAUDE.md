# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI短剧 APP — 对标红果短剧的短视频短剧平台 MVP。三端 mono-repo：

- **client/** — Flutter 移动客户端（iOS/macOS/Web）
- **server/** — Go 后端 API（Gin + GORM）
- **cms/** — React 管理后台（Vite + Ant Design）

## Build & Run Commands

### Go Backend (server/)

```bash
cd server
cp -n .env.example .env        # 首次需要
go mod tidy
go run ./cmd/api               # 默认 :8090，内存 mock 数据
go build ./cmd/api             # 编译检查
go test ./...                  # 测试
```

Go proxy 国内需要：`go env -w GOPROXY=https://goproxy.cn,direct`

### Flutter Client (client/)

```bash
cd client
flutter pub get
flutter analyze lib                                    # 静态检查
flutter run -d <device> --dart-define=API_BASE=http://localhost:8090  # 运行

# 设备选择
flutter run -d chrome                                  # Web
flutter run -d macos                                   # macOS 原生（固定 390×844）
flutter run -d <simulator-udid>                        # iOS 模拟器
flutter run -d web-server --web-port=3000              # Web server 模式
```

`--dart-define` 可注入两个编译期常量：
- `API_BASE` — 后端地址，默认 `http://localhost:8090`
- `USE_MOCK` — `true` 走本地 mock 数据，默认 `false`

### CMS Admin (cms/)

```bash
cd cms
npm install
npm run dev      # http://localhost:5173
npm run build    # 生产构建
npm run lint
```

CMS 登录：手机号 `admin`，验证码 `1234`（获得 admin role JWT）。

## Architecture

### 三层分离

```
Flutter Client  ──Dio──▶  Go Backend  ◀──fetch──  React CMS
                          (Gin + GORM)
                          ├─ memory repo (默认，零依赖)
                          └─ mysql repo  (DATA_SOURCE=mysql)
```

### Go Backend 分层 (server/internal/)

```
handler/  → HTTP 接入（参数校验 + 调 service + 返回 envelope）
service/  → 业务逻辑（drama/user/recommend/analytics）
repo/     → 数据访问接口 + memory/mysql 双实现（Repository Pattern）
model/    → GORM 实体
middleware/ → JWT / OptionalJWT / CORS / Recovery
```

`pkg/response/` 提供统一返回 envelope：`{ code: 0, message: "success", data: {} }`

### Flutter Client 分层 (client/lib/)

```
pages/    → 一个页面一个目录（home/player/detail/login/...）
widgets/  → 跨页面复用组件
services/ → API 客户端 / 鉴权 / 广告 / 埋点 / 本地存储
models/   → 不可变数据模型（copyWith + fromJson/toJson）
router/   → go_router 配置（ShellRoute 5 Tab + overlay 路由）
theme/    → 颜色/字体/圆角常量
```

状态管理用 `flutter_riverpod`（authProvider 是 StateNotifier）。

## API Routes

| 方法 | 路径 | 鉴权 |
|---|---|---|
| GET | `/health` | 无 |
| GET | `/api/v1/drama/feed?page=&pageSize=&category=` | 无 |
| GET | `/api/v1/drama/search?q=` | 无 |
| GET | `/api/v1/drama/recommend?limit=` | OptionalJWT |
| GET | `/api/v1/drama/:id` | 无 |
| GET | `/api/v1/drama/:id/episode/:ep` | 无 |
| POST | `/api/v1/user/login` | 无 |
| GET | `/api/v1/user/me` | JWT |
| POST | `/api/v1/user/sign-in` | JWT |
| POST | `/api/v1/analytics/events` | 无 |
| POST | `/api/v1/admin/drama/upload` | admin JWT |
| GET | `/api/v1/admin/stats` | admin JWT |
| GET | `/api/v1/admin/analytics` | admin JWT |

## Key Patterns

- **Repository Pattern**: `repo/` 定义接口，`memory_repo.go` 和 `mysql_repo.go` 各自实现。`main.go` 根据 `DATA_SOURCE` 环境变量选择注入。
- **Unified Envelope**: 所有 API 返回 `{ code, message, data }`，code=0 成功，非零错误。
- **OptionalJWT**: `/drama/recommend` 用可选鉴权 — 有 token 就解析出 userID 做个性化，没有也放行走热度排序。
- **Mock/Real Toggle**: Flutter 的 `FeedService` / `DramaService` 构造时传 `useMock`（默认读 `Env.useMock`），Go 后端用 `DATA_SOURCE=memory` 零依赖跑 mock 数据。
- **Ad SDK 抽象层**: `AdService` 接口 + `MockAdService` 实现，业务层不依赖任何广告联盟 SDK。
- **埋点批量上报**: Flutter `AnalyticsService` 攒满 10 条或 5 秒自动 flush 到 `POST /analytics/events`。

## Conventions

- 模型不可变（Dart 用 `copyWith`，Go struct 值类型）
- Flutter 页面只竖屏（`main.dart` 锁定 `portraitUp`）
- 色彩系统：主红 `#FF4D4F`、金色 `#FFD666`、深背景 `#0F0F10`、卡片 `#1A1A1C`
- iOS Info.plist 已配 ATS 豁免 localhost HTTP
- macOS 窗口固定 390×844（`MainFlutterWindow.swift`）
- Git push 如果 HTTP2 报错：`git -c http.version=HTTP/1.1 push`

## Gotchas

- Go 后端 `analytics_service.go` 当前是纯内存聚合，重启丢失
- 用户登录 MVP 固定验证码 `1234`，手机号 `admin` 签发 admin role
- CMS `api.js` 里后端地址硬编码 `http://localhost:8090`
- `video_player` 在 iOS 模拟器偶尔黑屏（已用 `FittedBox.cover` 缓解）
- Gin 路由 `/drama/search` 必须注册在 `/drama/:id` 之前，否则被参数路由吞掉
- Flutter `const []` 返回的 List 不可变，需要返回可变 `[]` 才能后续 insert/removeWhere
