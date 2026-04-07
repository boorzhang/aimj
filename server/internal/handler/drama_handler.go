// Package handler HTTP 接入层。
package handler

import (
	"errors"
	"strconv"

	"github.com/gin-gonic/gin"

	"github.com/aimj/server/internal/repo"
	"github.com/aimj/server/internal/service"
	"github.com/aimj/server/pkg/response"
)

// DramaHandler 剧集相关 HTTP handler
type DramaHandler struct {
	svc *service.DramaService
}

// NewDramaHandler 构造
func NewDramaHandler(svc *service.DramaService) *DramaHandler {
	return &DramaHandler{svc: svc}
}

// Feed GET /api/v1/drama/feed
func (h *DramaHandler) Feed(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	category := c.Query("category")

	result, err := h.svc.Feed(c.Request.Context(), page, pageSize, category)
	if err != nil {
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, result)
}

// Detail GET /api/v1/drama/:id
func (h *DramaHandler) Detail(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "invalid id")
		return
	}
	d, err := h.svc.Detail(c.Request.Context(), id)
	if err != nil {
		if errors.Is(err, repo.ErrNotFound) {
			response.NotFound(c, "drama not found")
			return
		}
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, d)
}

// Episode GET /api/v1/drama/:id/episode/:ep
func (h *DramaHandler) Episode(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "invalid id")
		return
	}
	ep, err := strconv.Atoi(c.Param("ep"))
	if err != nil || ep < 1 {
		response.BadRequest(c, "invalid episode")
		return
	}
	result, err := h.svc.Episode(c.Request.Context(), id, ep)
	if err != nil {
		if errors.Is(err, repo.ErrNotFound) {
			response.NotFound(c, "episode not found")
			return
		}
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, result)
}

// Create POST /api/v1/admin/drama/upload
func (h *DramaHandler) Create(c *gin.Context) {
	var in service.CreateDramaInput
	if err := c.ShouldBindJSON(&in); err != nil {
		response.BadRequest(c, err.Error())
		return
	}
	id, err := h.svc.Create(c.Request.Context(), in)
	if err != nil {
		response.Internal(c, err.Error())
		return
	}
	response.OK(c, gin.H{"id": id})
}
