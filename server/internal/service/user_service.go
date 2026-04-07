package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/aimj/server/internal/middleware"
	"github.com/aimj/server/internal/model"
	"github.com/aimj/server/internal/repo"
)

// UserService 用户业务
type UserService struct {
	repo      repo.UserRepo
	jwtSecret string
	jwtExpire time.Duration
}

// NewUserService 构造
func NewUserService(r repo.UserRepo, jwtSecret string, jwtExpire time.Duration) *UserService {
	return &UserService{repo: r, jwtSecret: jwtSecret, jwtExpire: jwtExpire}
}

// LoginInput 登录/注册入参
type LoginInput struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

// LoginResult 登录结果
type LoginResult struct {
	Token    string    `json:"token"`
	UserInfo UserInfo  `json:"user"`
	IsNew    bool      `json:"isNew"`
}

// UserInfo 用户信息 DTO
type UserInfo struct {
	ID       int64  `json:"id"`
	Phone    string `json:"phone"`
	Nickname string `json:"nickname"`
	Avatar   string `json:"avatar"`
	Coins    int64  `json:"coins"`
}

// SignInResult 签到结果
type SignInResult struct {
	ConsecutiveDays int   `json:"consecutiveDays"`
	CoinReward      int64 `json:"coinReward"`
	TotalCoins      int64 `json:"totalCoins"`
}

// Login 手机号+验证码登录（不存在则自动注册）
//
// MVP 阶段验证码固定 "1234" 通过，生产替换为 SMS SDK 校验。
func (s *UserService) Login(ctx context.Context, in LoginInput) (*LoginResult, error) {
	// MVP: 固定验证码 1234
	if in.Code != "1234" {
		return nil, errors.New("验证码错误")
	}

	var isNew bool
	user, err := s.repo.GetByPhone(ctx, in.Phone)
	if errors.Is(err, repo.ErrNotFound) {
		// 自动注册
		user = &model.User{
			Phone:    in.Phone,
			Nickname: fmt.Sprintf("用户%s", in.Phone[len(in.Phone)-4:]),
			Coins:    100, // 新人奖励
		}
		if err := s.repo.Create(ctx, user); err != nil {
			return nil, err
		}
		isNew = true
	} else if err != nil {
		return nil, err
	}

	// admin 手机号特殊处理，签发 admin role
	role := "user"
	if in.Phone == "admin" {
		role = "admin"
	}
	token, err := middleware.IssueToken(s.jwtSecret, user.ID, role, s.jwtExpire)
	if err != nil {
		return nil, err
	}

	return &LoginResult{
		Token: token,
		UserInfo: toUserInfo(user),
		IsNew: isNew,
	}, nil
}

// Me 获取当前用户信息
func (s *UserService) Me(ctx context.Context, userID int64) (*UserInfo, error) {
	user, err := s.repo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	info := toUserInfo(user)
	return &info, nil
}

// SignIn 每日签到
func (s *UserService) SignIn(ctx context.Context, userID int64) (*SignInResult, error) {
	signed, err := s.repo.HasSignedToday(ctx, userID)
	if err != nil {
		return nil, err
	}
	if signed {
		return nil, errors.New("今日已签到")
	}

	days, err := s.repo.RecordSignIn(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 签到奖励：基础 20 金币，连续 7 天翻倍
	reward := int64(20)
	if days >= 7 {
		reward = 50
	} else if days >= 3 {
		reward = 30
	}

	balance, err := s.repo.AddCoins(ctx, userID, reward, "daily_sign_in")
	if err != nil {
		return nil, err
	}

	return &SignInResult{
		ConsecutiveDays: days,
		CoinReward:      reward,
		TotalCoins:      balance,
	}, nil
}

// AddCoins 增加金币（广告奖励、任务奖励等）
func (s *UserService) AddCoins(ctx context.Context, userID int64, amount int64, reason string) (int64, error) {
	return s.repo.AddCoins(ctx, userID, amount, reason)
}

func toUserInfo(u *model.User) UserInfo {
	return UserInfo{
		ID:       u.ID,
		Phone:    u.Phone,
		Nickname: u.Nickname,
		Avatar:   u.Avatar,
		Coins:    u.Coins,
	}
}
