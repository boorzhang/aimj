package middleware

import (
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"

	"github.com/aimj/server/pkg/response"
)

// Claims JWT 自定义声明
type Claims struct {
	UserID int64  `json:"uid"`
	Role   string `json:"role"` // user / admin
	jwt.RegisteredClaims
}

// ContextKeyUserID gin.Context 中用户 ID 的 key
const ContextKeyUserID = "user_id"

// ContextKeyRole gin.Context 中角色的 key
const ContextKeyRole = "role"

// JWT 鉴权中间件
//
// requireAdmin=true 时仅允许 role=admin 访问。
func JWT(secret string, requireAdmin bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		auth := c.GetHeader("Authorization")
		if auth == "" || !strings.HasPrefix(auth, "Bearer ") {
			response.Unauthorized(c, "missing bearer token")
			return
		}
		tokenStr := strings.TrimPrefix(auth, "Bearer ")

		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (any, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrTokenUnverifiable
			}
			return []byte(secret), nil
		})
		if err != nil || !token.Valid {
			response.Unauthorized(c, "invalid token")
			return
		}

		if requireAdmin && claims.Role != "admin" {
			response.Fail(c, 403, response.CodeForbidden, "admin only")
			return
		}

		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyRole, claims.Role)
		c.Next()
	}
}

// OptionalJWT 可选鉴权：有 token 就解析注入，没有也放行。
func OptionalJWT(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		auth := c.GetHeader("Authorization")
		if auth == "" || !strings.HasPrefix(auth, "Bearer ") {
			c.Next()
			return
		}
		tokenStr := strings.TrimPrefix(auth, "Bearer ")
		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (any, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrTokenUnverifiable
			}
			return []byte(secret), nil
		})
		if err == nil && token.Valid {
			c.Set(ContextKeyUserID, claims.UserID)
			c.Set(ContextKeyRole, claims.Role)
		}
		c.Next()
	}
}

// IssueToken 签发 JWT（登录 / 注册 / CMS 登录调用）
func IssueToken(secret string, userID int64, role string, expire time.Duration) (string, error) {
	claims := Claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expire)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "aimj",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
