// Command api 启动 AI短剧 APP 后端服务。
//
// 用法：
//
//	cp .env.example .env
//	go run ./cmd/api
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

	// 根据 DATA_SOURCE 选择数据层实现
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
		userRepo = repo.NewMemoryUserRepo() // TODO: MySQL user repo
	default:
		log.Println("[main] running with in-memory mock repo")
		dramaRepo = repo.NewMemoryDramaRepo()
		userRepo = repo.NewMemoryUserRepo()
	}

	dramaSvc := service.NewDramaService(dramaRepo, cfg.CDNBase)
	dramaH := handler.NewDramaHandler(dramaSvc)

	userSvc := service.NewUserService(userRepo, cfg.JWTSecret, cfg.JWTExpire)
	userH := handler.NewUserHandler(userSvc)

	r := router.Setup(cfg, dramaH, userH)

	addr := ":" + cfg.AppPort
	log.Printf("[main] server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("[main] server run failed: %v", err)
	}
}
