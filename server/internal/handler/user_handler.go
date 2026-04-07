package handler

import (
	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/middleware"
	"github.com/aimj/server/internal/service"
	"github.com/aimj/server/pkg/response"
)

// UserHandler 用户相关 HTTP handler
type UserHandler struct {
	svc *service.UserService
}

// NewUserHandler 构造
func NewUserHandler(svc *service.UserService) *UserHandler {
	return &UserHandler{svc: svc}
}

// Login POST /api/v1/user/login
func (h *UserHandler) Login(c *gin.Context) {
	var in service.LoginInput
	if err := c.ShouldBindJSON(&in); err != nil {
		response.BadRequest(c, err.Error())
		return
	}
	result, err := h.svc.Login(c.Request.Context(), in)
	if err != nil {
		response.BadRequest(c, err.Error())
		return
	}
	response.OK(c, result)
}

// Me GET /api/v1/user/me
func (h *UserHandler) Me(c *gin.Context) {
	uid, _ := c.Get(middleware.ContextKeyUserID)
	userID, _ := uid.(int64)
	info, err := h.svc.Me(c.Request.Context(), userID)
	if err != nil {
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, info)
}

// SignIn POST /api/v1/user/sign-in
func (h *UserHandler) SignIn(c *gin.Context) {
	uid, _ := c.Get(middleware.ContextKeyUserID)
	userID, _ := uid.(int64)
	result, err := h.svc.SignIn(c.Request.Context(), userID)
	if err != nil {
		response.BadRequest(c, err.Error())
		return
	}
	response.OK(c, result)
}
