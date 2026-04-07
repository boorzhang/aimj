package repo

import (
	"context"

	"github.com/aimj/server/internal/model"
)

// UserRepo 用户数据访问接口
type UserRepo interface {
	GetByID(ctx context.Context, id int64) (*model.User, error)
	GetByPhone(ctx context.Context, phone string) (*model.User, error)
	Create(ctx context.Context, user *model.User) error
	Update(ctx context.Context, user *model.User) error

	// SignIn 签到：记录今日已签到，返回连续签到天数
	HasSignedToday(ctx context.Context, userID int64) (bool, error)
	RecordSignIn(ctx context.Context, userID int64) (consecutiveDays int, err error)

	// AddCoins 增减金币（正数加，负数减），返回操作后余额
	AddCoins(ctx context.Context, userID int64, delta int64, reason string) (balance int64, err error)
}
