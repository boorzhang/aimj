package model

import "time"

// User 用户
type User struct {
	ID        int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	Phone     string    `gorm:"size:32;uniqueIndex" json:"phone"`
	Nickname  string    `gorm:"size:64" json:"nickname"`
	Avatar    string    `gorm:"size:512" json:"avatar"`
	Coins     int64     `gorm:"default:0" json:"coins"`
	VipUntil  *time.Time `json:"vipUntil,omitempty"`
	CreatedAt time.Time  `json:"-"`
	UpdatedAt time.Time  `json:"-"`
}

func (User) TableName() string { return "user" }
