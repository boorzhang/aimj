package model

import "time"

// Episode 分集
//
// 对应接口：GET /api/v1/drama/:id/episode/:ep
type Episode struct {
	ID        int64     `gorm:"primaryKey;autoIncrement" json:"-"`
	DramaID   int64     `gorm:"index:idx_drama_ep,unique,priority:1;not null" json:"-"`
	Episode   int       `gorm:"index:idx_drama_ep,unique,priority:2;not null" json:"episode"`
	Duration  int       `gorm:"default:0" json:"duration"` // 秒
	VideoKey  string    `gorm:"size:512" json:"-"`          // OSS key，下发时拼 CDN
	Locked    bool      `gorm:"default:false" json:"locked"`
	CreatedAt time.Time `json:"-"`
	UpdatedAt time.Time `json:"-"`
}

func (Episode) TableName() string { return "episode" }
