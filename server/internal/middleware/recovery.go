package middleware

import (
	"log"
	"runtime/debug"

	"github.com/gin-gonic/gin"

	"github.com/aimj/server/pkg/response"
)

// Recovery panic 捕获 + 统一错误返回
func Recovery() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("[panic] %v\n%s", err, debug.Stack())
				response.Internal(c, "internal server error")
			}
		}()
		c.Next()
	}
}
