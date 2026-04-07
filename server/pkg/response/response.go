// Package response 统一 API 返回 envelope
//
// 对齐 docs/研发联调级文档API级别.md §13.1:
//
//	{
//	  "code": 0,
//	  "message": "success",
//	  "data": {}
//	}
package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Envelope 统一响应
type Envelope struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    any    `json:"data"`
}

// 常用错误码
const (
	CodeOK           = 0
	CodeBadRequest   = 40000
	CodeUnauthorized = 40100
	CodeForbidden    = 40300
	CodeNotFound     = 40400
	CodeInternal     = 50000
)

// OK 返回成功
func OK(c *gin.Context, data any) {
	c.JSON(http.StatusOK, Envelope{Code: CodeOK, Message: "success", Data: data})
}

// Fail 返回错误
func Fail(c *gin.Context, httpStatus, code int, message string) {
	c.AbortWithStatusJSON(httpStatus, Envelope{Code: code, Message: message, Data: nil})
}

// BadRequest 400
func BadRequest(c *gin.Context, message string) {
	Fail(c, http.StatusBadRequest, CodeBadRequest, message)
}

// Unauthorized 401
func Unauthorized(c *gin.Context, message string) {
	if message == "" {
		message = "unauthorized"
	}
	Fail(c, http.StatusUnauthorized, CodeUnauthorized, message)
}

// NotFound 404
func NotFound(c *gin.Context, message string) {
	if message == "" {
		message = "not found"
	}
	Fail(c, http.StatusNotFound, CodeNotFound, message)
}

// Internal 500
func Internal(c *gin.Context, message string) {
	if message == "" {
		message = "internal error"
	}
	Fail(c, http.StatusInternalServerError, CodeInternal, message)
}
