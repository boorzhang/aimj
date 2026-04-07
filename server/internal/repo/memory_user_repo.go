package repo

import (
	"context"
	"sync"
	"time"

	"github.com/aimj/server/internal/model"
)

// NewMemoryUserRepo 构造内存 mock 用户 repo
func NewMemoryUserRepo() UserRepo {
	return &memoryUserRepo{
		users:    make(map[int64]*model.User),
		phones:   make(map[string]int64),
		signIns:  make(map[int64]signInRecord),
		watches:  make(map[int64][]int64),
	}
}

type signInRecord struct {
	lastDate       string // "2006-01-02"
	consecutiveDays int
}

type memoryUserRepo struct {
	mu      sync.RWMutex
	users   map[int64]*model.User
	phones  map[string]int64 // phone -> userID
	signIns map[int64]signInRecord
	watches map[int64][]int64 // userID -> dramaIDs (去重有序)
	nextID  int64
}

func (r *memoryUserRepo) GetByID(_ context.Context, id int64) (*model.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	u, ok := r.users[id]
	if !ok {
		return nil, ErrNotFound
	}
	cp := *u
	return &cp, nil
}

func (r *memoryUserRepo) GetByPhone(_ context.Context, phone string) (*model.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	id, ok := r.phones[phone]
	if !ok {
		return nil, ErrNotFound
	}
	cp := *r.users[id]
	return &cp, nil
}

func (r *memoryUserRepo) Create(_ context.Context, user *model.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.nextID++
	user.ID = r.nextID
	now := time.Now()
	user.CreatedAt = now
	user.UpdatedAt = now
	cp := *user
	r.users[user.ID] = &cp
	r.phones[user.Phone] = user.ID
	return nil
}

func (r *memoryUserRepo) Update(_ context.Context, user *model.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.users[user.ID]; !ok {
		return ErrNotFound
	}
	user.UpdatedAt = time.Now()
	cp := *user
	r.users[user.ID] = &cp
	return nil
}

func (r *memoryUserRepo) HasSignedToday(_ context.Context, userID int64) (bool, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	rec, ok := r.signIns[userID]
	if !ok {
		return false, nil
	}
	today := time.Now().Format("2006-01-02")
	return rec.lastDate == today, nil
}

func (r *memoryUserRepo) RecordSignIn(_ context.Context, userID int64) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	today := time.Now().Format("2006-01-02")
	yesterday := time.Now().AddDate(0, 0, -1).Format("2006-01-02")

	rec := r.signIns[userID]
	if rec.lastDate == today {
		return rec.consecutiveDays, nil // 已签过
	}
	if rec.lastDate == yesterday {
		rec.consecutiveDays++
	} else {
		rec.consecutiveDays = 1
	}
	rec.lastDate = today
	r.signIns[userID] = rec
	return rec.consecutiveDays, nil
}

func (r *memoryUserRepo) AddCoins(_ context.Context, userID int64, delta int64, _ string) (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	u, ok := r.users[userID]
	if !ok {
		return 0, ErrNotFound
	}
	u.Coins += delta
	if u.Coins < 0 {
		u.Coins = 0
	}
	return u.Coins, nil
}

func (r *memoryUserRepo) RecordWatch(_ context.Context, userID int64, dramaID int64, _ int) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	ids := r.watches[userID]
	for _, id := range ids {
		if id == dramaID {
			return nil // 已记录
		}
	}
	r.watches[userID] = append(ids, dramaID)
	return nil
}

func (r *memoryUserRepo) WatchedDramaIDs(_ context.Context, userID int64) ([]int64, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	ids := r.watches[userID]
	out := make([]int64, len(ids))
	copy(out, ids)
	return out, nil
}
