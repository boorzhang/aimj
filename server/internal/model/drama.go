package model

import "time"

// Drama 剧集主表
//
// 对应接口：
//   - GET /api/v1/drama/feed
//   - GET /api/v1/drama/:id
type Drama struct {
	ID           int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	Title        string    `gorm:"size:128;not null;index" json:"title"`
	Cover        string    `gorm:"size:512" json:"cover"`
	Description  string    `gorm:"type:text" json:"description"`
	Category     string    `gorm:"size:32;index" json:"category"` // male / female / mystery / scifi ...
	Tags         string    `gorm:"size:256" json:"-"`              // 逗号分隔落库
	EpisodeCount int       `gorm:"default:0" json:"episodeCount"`
	UpdatedTo    int       `gorm:"default:0" json:"updatedTo"`
	Heat         int64     `gorm:"default:0;index" json:"heat"`
	Status       int       `gorm:"default:1;index" json:"-"` // 1 上架 0 下架
	Weight       int       `gorm:"default:0" json:"-"`        // 推荐权重
	CreatedAt    time.Time `json:"-"`
	UpdatedAt    time.Time `json:"-"`
}

// TableName 自定义表名
func (Drama) TableName() string { return "drama" }
