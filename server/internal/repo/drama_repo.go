// Package repo 数据访问层。
//
// 遵循 Repository Pattern：业务层依赖接口，具体实现可切 memory / mysql。
package repo

import (
	"context"
	"errors"

	"github.com/aimj/server/internal/model"
)

// ErrNotFound 资源不存在
var ErrNotFound = errors.New("not found")

// ListDramaParams 列表查询参数
type ListDramaParams struct {
	Page     int
	PageSize int
	Category string
}

// ListDramaResult 列表查询结果
type ListDramaResult struct {
	List    []model.Drama
	HasMore bool
	Total   int64
}

// DramaRepo 剧集数据访问接口
type DramaRepo interface {
	List(ctx context.Context, params ListDramaParams) (ListDramaResult, error)
	GetByID(ctx context.Context, id int64) (*model.Drama, error)
	Create(ctx context.Context, drama *model.Drama) error

	// Episodes 剧集下所有分集（按集序升序）
	Episodes(ctx context.Context, dramaID int64) ([]model.Episode, error)
	GetEpisode(ctx context.Context, dramaID int64, ep int) (*model.Episode, error)
	CreateEpisodes(ctx context.Context, episodes []model.Episode) error
}
