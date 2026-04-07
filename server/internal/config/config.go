// Package config 加载环境变量配置。
package config

import (
	"log"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config 运行时配置
type Config struct {
	AppEnv     string
	AppPort    string
	DataSource string // memory | mysql
	MySQLDSN   string
	JWTSecret  string
	JWTExpire  time.Duration
	CDNBase    string
}

// Load 从 .env 和环境变量加载配置
func Load() *Config {
	if err := godotenv.Load(); err != nil {
		log.Printf("[config] no .env loaded: %v", err)
	}

	expireH, _ := strconv.Atoi(getEnv("JWT_EXPIRE_HOURS", "168"))

	return &Config{
		AppEnv:     getEnv("APP_ENV", "dev"),
		AppPort:    getEnv("APP_PORT", "8080"),
		DataSource: getEnv("DATA_SOURCE", "memory"),
		MySQLDSN:   getEnv("MYSQL_DSN", ""),
		JWTSecret:  getEnv("JWT_SECRET", "dev-secret-change-me"),
		JWTExpire:  time.Duration(expireH) * time.Hour,
		CDNBase:    getEnv("CDN_BASE", ""),
	}
}

func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}
