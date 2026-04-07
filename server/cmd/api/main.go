package main

import (
	"log"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"github.com/aimj/server/internal/config"
	"github.com/aimj/server/internal/handler"
	"github.com/aimj/server/internal/repo"
	"github.com/aimj/server/internal/router"
	"github.com/aimj/server/internal/service"
)

func main() {
	cfg := config.Load()

	var dramaRepo repo.DramaRepo
	var userRepo repo.UserRepo
	switch cfg.DataSource {
	case "mysql":
		db, err := gorm.Open(mysql.Open(cfg.MySQLDSN), &gorm.Config{})
		if err != nil {
			log.Fatalf("[main] connect mysql failed: %v", err)
		}
		log.Println("[main] mysql connected")
		dramaRepo = repo.NewMySQLDramaRepo(db)
		userRepo = repo.NewMemoryUserRepo()
	default:
		log.Println("[main] running with in-memory mock repo")
		dramaRepo = repo.NewMemoryDramaRepo()
		userRepo = repo.NewMemoryUserRepo()
	}

	dramaSvc := service.NewDramaService(dramaRepo, cfg.CDNBase)
	dramaH := handler.NewDramaHandler(dramaSvc)

	userSvc := service.NewUserService(userRepo, cfg.JWTSecret, cfg.JWTExpire)
	userH := handler.NewUserHandler(userSvc)

	recSvc := service.NewRecommendService(dramaRepo, userRepo, cfg.CDNBase)
	recH := handler.NewRecommendHandler(recSvc)

	analyticsSvc := service.NewAnalyticsService()
	analyticsH := handler.NewAnalyticsHandler(analyticsSvc)

	r := router.Setup(cfg, dramaH, userH, recH, analyticsH)

	addr := ":" + cfg.AppPort
	log.Printf("[main] server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("[main] server run failed: %v", err)
	}
}
