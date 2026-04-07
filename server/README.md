# AI短剧 APP · Go 后端

对齐 `docs/研发联调级文档API级别.md` §13 的后端服务。Gin + GORM + MySQL。

## 技术栈

- Go 1.22+
- Web：`gin-gonic/gin`
- ORM：`gorm.io/gorm` + `gorm.io/driver/mysql`
- 鉴权：`golang-jwt/jwt/v5`
- 配置：`godotenv`（可切 Viper）

## 目录结构

```
server/
├── cmd/api/main.go              # 入口
├── internal/
│   ├── config/                  # 配置加载
│   ├── router/                  # 路由装配
│   ├── middleware/              # JWT / CORS / Logger
│   ├── model/                   # GORM 实体
│   ├── repo/                    # 数据访问层（接口 + 内存/MySQL 两种实现）
│   ├── service/                 # 业务逻辑
│   └── handler/                 # HTTP handler
├── pkg/response/                # 统一返回 envelope
├── migrations/
│   └── 001_init.sql
├── .env.example
├── go.mod
└── README.md
```

## 快速开始

### 零依赖联调模式（内存 mock）

```bash
cd server
cp .env.example .env
# 默认 DATA_SOURCE=memory，无需 MySQL
go mod tidy
go run ./cmd/api
```

启动后访问：

```bash
curl http://localhost:8080/health
curl http://localhost:8080/api/v1/drama/feed?page=1
curl http://localhost:8080/api/v1/drama/1001
curl http://localhost:8080/api/v1/drama/1001/episode/1
```

### MySQL 模式

```bash
mysql -u root -p < migrations/001_init.sql
# 改 .env: DATA_SOURCE=mysql
go run ./cmd/api
```

## 核心接口（对齐 docs §13）

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/health` | 健康检查 |
| GET | `/api/v1/drama/feed` | 首页推荐流 |
| GET | `/api/v1/drama/:id` | 剧集详情 |
| GET | `/api/v1/drama/:id/episode/:ep` | 分集播放地址 |
| POST | `/api/v1/admin/drama/upload` | CMS 剧集上传 (JWT) |

### 统一返回结构

```json
{
  "code": 0,
  "message": "success",
  "data": { /* ... */ }
}
```

- `code=0` 成功，非零为错误
- `401` JWT 缺失/过期
- `404` 资源不存在
- `500` 服务端异常

## 联调与 Flutter 客户端对接

Flutter 端在 `client/lib/services/` 下把 `useMock` 改为 `false`，并把 `api_client.dart` 的 `baseUrl` 指向 `http://<your-ip>:8080` 即可。
