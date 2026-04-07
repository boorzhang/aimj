// Package router 装配 HTTP 路由。
package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/config"
	"github.com/aimj/server/internal/handler"
	"github.com/aimj/server/internal/middleware"
)

// Setup 构造并返回 *gin.Engine
func Setup(cfg *config.Config, dramaH *handler.DramaHandler) *gin.Engine {
	if cfg.AppEnv == "prod" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.New()
	r.Use(gin.Logger())
	r.Use(middleware.Recovery())
	r.Use(middleware.CORS())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"env":    cfg.AppEnv,
			"source": cfg.DataSource,
		})
	})

	// 公开接口
	v1 := r.Group("/api/v1")
	{
		drama := v1.Group("/drama")
		{
			drama.GET("/feed", dramaH.Feed)
			drama.GET("/search", dramaH.Search)
			drama.GET("/:id", dramaH.Detail)
			drama.GET("/:id/episode/:ep", dramaH.Episode)
		}
	}

	// CMS 管理接口（需要 admin JWT）
	admin := r.Group("/api/v1/admin",
		middleware.JWT(cfg.JWTSecret, true),
	)
	{
		admin.POST("/drama/upload", dramaH.Create)
	}

	return r
}
