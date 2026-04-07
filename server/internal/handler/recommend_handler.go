package handler

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/middleware"
	"github.com/aimj/server/internal/service"
	"github.com/aimj/server/pkg/response"
)

type RecommendHandler struct {
	svc *service.RecommendService
}

func NewRecommendHandler(svc *service.RecommendService) *RecommendHandler {
	return &RecommendHandler{svc: svc}
}

// Recommend GET /api/v1/drama/recommend?limit=20
func (h *RecommendHandler) Recommend(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	// 可选登录：有 token 则用，无 token 则 userID=0
	var userID int64
	if uid, exists := c.Get(middleware.ContextKeyUserID); exists {
		userID, _ = uid.(int64)
	}

	result, err := h.svc.Recommend(c.Request.Context(), userID, limit)
	if err != nil {
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, result)
}
