package repo

import (
	"context"
	"sort"
	"sync"
	"time"

	"github.com/aimj/server/internal/model"
)

// NewMemoryDramaRepo 构造内存 mock repo（含种子数据）
//
// 用于前端联调，避免强依赖 MySQL 即可跑通全链路。
func NewMemoryDramaRepo() DramaRepo {
	r := &memoryDramaRepo{
		dramas:   make(map[int64]*model.Drama),
		episodes: make(map[int64][]model.Episode),
	}
	r.seed()
	return r
}

type memoryDramaRepo struct {
	mu       sync.RWMutex
	dramas   map[int64]*model.Drama
	episodes map[int64][]model.Episode // dramaID -> episodes
	nextID   int64
}

// 国内可达的公开 mp4 样片 —— 已验证 200 OK，无需鉴权。
// 每集轮播一条，观感接近真实连播。
// 来源：W3C media / video.js demo / runoob 教学样片。
var publicSampleVideos = []string{
	"https://media.w3.org/2010/05/sintel/trailer.mp4",
	"https://media.w3.org/2010/05/sintel/trailer_hd.mp4",
	"https://media.w3.org/2010/05/bunny/trailer.mp4",
	"https://media.w3.org/2010/05/bunny/movie.mp4",
	"https://media.w3.org/2010/05/video/movie_300.mp4",
	"https://vjs.zencdn.net/v/oceans.mp4",
	"https://www.runoob.com/try/demo_source/mov_bbb.mp4",
	"https://www.runoob.com/try/demo_source/movie.mp4",
}

func (r *memoryDramaRepo) seed() {
	titles := []struct {
		title, cat, tags string
	}{
		{"重生归来：豪门逆袭", "male", "重生,逆袭"},
		{"战神不败：都市神王", "female", "战神,都市"},
		{"赘婿崛起：复仇之路", "male", "赘婿,复仇"},
		{"甜宠总裁的心尖宝", "female", "甜宠,总裁"},
		{"时间循环：重回高考", "male", "科幻,悬疑"},
		{"赛博都市：AI恋人", "female", "AI,恋爱"},
		{"医武双修：回到校园", "male", "医武,校园"},
		{"豪门千金归来", "female", "豪门,女频"},
		{"穿越王朝：女相权谋", "male", "古风,权谋"},
		{"废柴逆袭：系统降临", "female", "系统,爽文"},
		{"末日觉醒：我是最强", "male", "末日,觉醒"},
		{"平行宇宙：另一个我", "female", "平行,脑洞"},
	}

	now := time.Now()
	for i, t := range titles {
		id := int64(1000 + i)
		d := &model.Drama{
			ID:           id,
			Title:        t.title,
			Description:  t.title + " - AI 生成短剧，每日更新，追更爽到飞起。",
			Category:     t.cat,
			Tags:         t.tags,
			EpisodeCount: 60,
			UpdatedTo:    20 + (i*3)%40,
			Heat:         int64(100000 + i*87654),
			Status:       1,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		r.dramas[id] = d

		eps := make([]model.Episode, 0, d.EpisodeCount)
		for ep := 1; ep <= d.EpisodeCount; ep++ {
			// 每集换一条样片，观感接近真实连播
			video := publicSampleVideos[(i+ep)%len(publicSampleVideos)]
			eps = append(eps, model.Episode{
				DramaID:   id,
				Episode:   ep,
				Duration:  90 + (ep%5)*10,
				VideoKey:  video,
				Locked:    ep > 10,
				CreatedAt: now,
				UpdatedAt: now,
			})
		}
		r.episodes[id] = eps
	}
	r.nextID = 1000 + int64(len(titles))
}

func (r *memoryDramaRepo) List(ctx context.Context, params ListDramaParams) (ListDramaResult, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	if params.Page < 1 {
		params.Page = 1
	}
	if params.PageSize <= 0 {
		params.PageSize = 20
	}

	filtered := make([]model.Drama, 0, len(r.dramas))
	for _, d := range r.dramas {
		if d.Status != 1 {
			continue
		}
		if params.Category != "" && d.Category != params.Category {
			continue
		}
		filtered = append(filtered, *d)
	}

	// 按热度倒序
	sort.Slice(filtered, func(i, j int) bool {
		return filtered[i].Heat > filtered[j].Heat
	})

	total := int64(len(filtered))
	start := (params.Page - 1) * params.PageSize
	end := start + params.PageSize
	if start >= len(filtered) {
		return ListDramaResult{List: []model.Drama{}, HasMore: false, Total: total}, nil
	}
	if end > len(filtered) {
		end = len(filtered)
	}

	return ListDramaResult{
		List:    filtered[start:end],
		HasMore: end < len(filtered),
		Total:   total,
	}, nil
}

func (r *memoryDramaRepo) GetByID(ctx context.Context, id int64) (*model.Drama, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	d, ok := r.dramas[id]
	if !ok {
		return nil, ErrNotFound
	}
	copy := *d
	return &copy, nil
}

func (r *memoryDramaRepo) Create(ctx context.Context, drama *model.Drama) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if drama.ID == 0 {
		r.nextID++
		drama.ID = r.nextID
	}
	now := time.Now()
	drama.CreatedAt = now
	drama.UpdatedAt = now
	copy := *drama
	r.dramas[drama.ID] = &copy
	return nil
}

func (r *memoryDramaRepo) Episodes(ctx context.Context, dramaID int64) ([]model.Episode, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	eps, ok := r.episodes[dramaID]
	if !ok {
		return nil, ErrNotFound
	}
	out := make([]model.Episode, len(eps))
	copy(out, eps)
	return out, nil
}

func (r *memoryDramaRepo) GetEpisode(ctx context.Context, dramaID int64, ep int) (*model.Episode, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	eps, ok := r.episodes[dramaID]
	if !ok {
		return nil, ErrNotFound
	}
	for i := range eps {
		if eps[i].Episode == ep {
			copy := eps[i]
			return &copy, nil
		}
	}
	return nil, ErrNotFound
}

func (r *memoryDramaRepo) CreateEpisodes(ctx context.Context, episodes []model.Episode) error {
	if len(episodes) == 0 {
		return nil
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	dramaID := episodes[0].DramaID
	now := time.Now()
	next := make([]model.Episode, 0, len(episodes))
	for _, e := range episodes {
		e.CreatedAt = now
		e.UpdatedAt = now
		next = append(next, e)
	}
	r.episodes[dramaID] = append(r.episodes[dramaID], next...)
	// 更新剧集计数
	if d, ok := r.dramas[dramaID]; ok {
		d.EpisodeCount = len(r.episodes[dramaID])
		d.UpdatedAt = now
	}
	return nil
}
