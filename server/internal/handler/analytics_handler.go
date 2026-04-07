package handler

import (
	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/service"
	"github.com/aimj/server/pkg/response"
)

type AnalyticsHandler struct {
	svc *service.AnalyticsService
}

func NewAnalyticsHandler(svc *service.AnalyticsService) *AnalyticsHandler {
	return &AnalyticsHandler{svc: svc}
}

// Report POST /api/v1/analytics/events
func (h *AnalyticsHandler) Report(c *gin.Context) {
	var in service.BatchInput
	if err := c.ShouldBindJSON(&in); err != nil {
		response.BadRequest(c, err.Error())
		return
	}
	h.svc.Record(in.Events)
	response.OK(c, gin.H{"accepted": len(in.Events)})
}

// Summary GET /api/v1/admin/analytics
func (h *AnalyticsHandler) Summary(c *gin.Context) {
	response.OK(c, h.svc.Summary())
}
