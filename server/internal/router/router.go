package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/config"
	"github.com/aimj/server/internal/handler"
	"github.com/aimj/server/internal/middleware"
)

// Setup 构造并返回 *gin.Engine
func Setup(
	cfg *config.Config,
	dramaH *handler.DramaHandler,
	userH *handler.UserHandler,
	recH *handler.RecommendHandler,
	analyticsH *handler.AnalyticsHandler,
) *gin.Engine {
	if cfg.AppEnv == "prod" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.New()
	r.Use(gin.Logger())
	r.Use(middleware.Recovery())
	r.Use(middleware.CORS())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"env":    cfg.AppEnv,
			"source": cfg.DataSource,
		})
	})

	optionalAuth := middleware.OptionalJWT(cfg.JWTSecret)

	v1 := r.Group("/api/v1")
	{
		drama := v1.Group("/drama")
		{
			drama.GET("/feed", dramaH.Feed)
			drama.GET("/search", dramaH.Search)
			drama.GET("/recommend", optionalAuth, recH.Recommend)
			drama.GET("/:id", dramaH.Detail)
			drama.GET("/:id/episode/:ep", dramaH.Episode)
		}

		v1.POST("/user/login", userH.Login)

		// 埋点上报（公开，无需登录）
		v1.POST("/analytics/events", analyticsH.Report)
	}

	// 需要登录
	auth := r.Group("/api/v1", middleware.JWT(cfg.JWTSecret, false))
	{
		user := auth.Group("/user")
		{
			user.GET("/me", userH.Me)
			user.POST("/sign-in", userH.SignIn)
		}
	}

	// CMS 管理（admin JWT）
	admin := r.Group("/api/v1/admin", middleware.JWT(cfg.JWTSecret, true))
	{
		admin.POST("/drama/upload", dramaH.Create)
		admin.GET("/stats", dramaH.Stats)
		admin.GET("/analytics", analyticsH.Summary)
	}

	return r
}
