package repo

import (
	"context"
	"errors"

	"gorm.io/gorm"

	"github.com/aimj/server/internal/model"
)

// NewMySQLDramaRepo 构造基于 GORM/MySQL 的 repo
func NewMySQLDramaRepo(db *gorm.DB) DramaRepo {
	return &mysqlDramaRepo{db: db}
}

type mysqlDramaRepo struct {
	db *gorm.DB
}

func (r *mysqlDramaRepo) List(ctx context.Context, params ListDramaParams) (ListDramaResult, error) {
	if params.Page < 1 {
		params.Page = 1
	}
	if params.PageSize <= 0 {
		params.PageSize = 20
	}

	q := r.db.WithContext(ctx).Model(&model.Drama{}).Where("status = ?", 1)
	if params.Category != "" {
		q = q.Where("category = ?", params.Category)
	}

	var total int64
	if err := q.Count(&total).Error; err != nil {
		return ListDramaResult{}, err
	}

	var list []model.Drama
	offset := (params.Page - 1) * params.PageSize
	if err := q.Order("weight DESC, heat DESC").
		Offset(offset).Limit(params.PageSize).
		Find(&list).Error; err != nil {
		return ListDramaResult{}, err
	}

	return ListDramaResult{
		List:    list,
		HasMore: int64(offset+len(list)) < total,
		Total:   total,
	}, nil
}

func (r *mysqlDramaRepo) GetByID(ctx context.Context, id int64) (*model.Drama, error) {
	var d model.Drama
	if err := r.db.WithContext(ctx).First(&d, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &d, nil
}

func (r *mysqlDramaRepo) Create(ctx context.Context, drama *model.Drama) error {
	return r.db.WithContext(ctx).Create(drama).Error
}

func (r *mysqlDramaRepo) Episodes(ctx context.Context, dramaID int64) ([]model.Episode, error) {
	var list []model.Episode
	if err := r.db.WithContext(ctx).
		Where("drama_id = ?", dramaID).
		Order("episode ASC").
		Find(&list).Error; err != nil {
		return nil, err
	}
	return list, nil
}

func (r *mysqlDramaRepo) GetEpisode(ctx context.Context, dramaID int64, ep int) (*model.Episode, error) {
	var e model.Episode
	if err := r.db.WithContext(ctx).
		Where("drama_id = ? AND episode = ?", dramaID, ep).
		First(&e).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &e, nil
}

func (r *mysqlDramaRepo) CreateEpisodes(ctx context.Context, episodes []model.Episode) error {
	if len(episodes) == 0 {
		return nil
	}
	return r.db.WithContext(ctx).Create(&episodes).Error
}
