// Package service 业务逻辑层。
package service

import (
	"context"
	"strings"

	"github.com/aimj/server/internal/model"
	"github.com/aimj/server/internal/repo"
)

// DramaService 剧集业务服务
type DramaService struct {
	repo    repo.DramaRepo
	cdnBase string
}

// NewDramaService 构造
func NewDramaService(r repo.DramaRepo, cdnBase string) *DramaService {
	return &DramaService{repo: r, cdnBase: strings.TrimRight(cdnBase, "/")}
}

// DramaListItem 列表元素（feed DTO）
type DramaListItem struct {
	ID           int64    `json:"id"`
	Title        string   `json:"title"`
	Cover        string   `json:"cover"`
	Tags         []string `json:"tags"`
	EpisodeCount int      `json:"episodeCount"`
	UpdatedTo    int      `json:"updatedTo"`
	Heat         int64    `json:"heat"`
}

// FeedResult feed 接口返回
type FeedResult struct {
	List    []DramaListItem `json:"list"`
	HasMore bool            `json:"hasMore"`
}

// DramaDetail 详情返回
type DramaDetail struct {
	ID           int64         `json:"id"`
	Title        string        `json:"title"`
	Description  string        `json:"description"`
	Cover        string        `json:"cover"`
	Tags         []string      `json:"tags"`
	Category     string        `json:"category"`
	EpisodeCount int           `json:"episodeCount"`
	UpdatedTo    int           `json:"updatedTo"`
	Heat         int64         `json:"heat"`
	Episodes     []EpisodeBrief `json:"episodes"`
}

// EpisodeBrief 详情中的分集概要
type EpisodeBrief struct {
	Episode  int  `json:"episode"`
	Duration int  `json:"duration"`
	Locked   bool `json:"locked"`
}

// EpisodePlay 播放地址返回
type EpisodePlay struct {
	Episode      int    `json:"episode"`
	VideoURL     string `json:"videoUrl"`
	NextEpisode  int    `json:"nextEpisode"`
	NeedAdUnlock bool   `json:"needAdUnlock"`
	UnlockType   string `json:"unlockType"`
}

// Search 关键词搜索
func (s *DramaService) Search(ctx context.Context, query string, limit int) ([]DramaListItem, error) {
	list, err := s.repo.Search(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	items := make([]DramaListItem, 0, len(list))
	for _, d := range list {
		items = append(items, DramaListItem{
			ID:           d.ID,
			Title:        d.Title,
			Cover:        s.coverURL(d.Cover),
			Tags:         splitTags(d.Tags),
			EpisodeCount: d.EpisodeCount,
			UpdatedTo:    d.UpdatedTo,
			Heat:         d.Heat,
		})
	}
	return items, nil
}

// Feed 首页推荐流
func (s *DramaService) Feed(ctx context.Context, page, pageSize int, category string) (FeedResult, error) {
	r, err := s.repo.List(ctx, repo.ListDramaParams{
		Page:     page,
		PageSize: pageSize,
		Category: category,
	})
	if err != nil {
		return FeedResult{}, err
	}
	items := make([]DramaListItem, 0, len(r.List))
	for _, d := range r.List {
		items = append(items, DramaListItem{
			ID:           d.ID,
			Title:        d.Title,
			Cover:        s.coverURL(d.Cover),
			Tags:         splitTags(d.Tags),
			EpisodeCount: d.EpisodeCount,
			UpdatedTo:    d.UpdatedTo,
			Heat:         d.Heat,
		})
	}
	return FeedResult{List: items, HasMore: r.HasMore}, nil
}

// Detail 剧集详情
func (s *DramaService) Detail(ctx context.Context, id int64) (*DramaDetail, error) {
	d, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	eps, err := s.repo.Episodes(ctx, id)
	if err != nil && err != repo.ErrNotFound {
		return nil, err
	}
	brief := make([]EpisodeBrief, 0, len(eps))
	for _, e := range eps {
		brief = append(brief, EpisodeBrief{
			Episode:  e.Episode,
			Duration: e.Duration,
			Locked:   e.Locked,
		})
	}
	return &DramaDetail{
		ID:           d.ID,
		Title:        d.Title,
		Description:  d.Description,
		Cover:        s.coverURL(d.Cover),
		Tags:         splitTags(d.Tags),
		Category:     d.Category,
		EpisodeCount: d.EpisodeCount,
		UpdatedTo:    d.UpdatedTo,
		Heat:         d.Heat,
		Episodes:     brief,
	}, nil
}

// Episode 获取分集播放地址
func (s *DramaService) Episode(ctx context.Context, dramaID int64, ep int) (*EpisodePlay, error) {
	e, err := s.repo.GetEpisode(ctx, dramaID, ep)
	if err != nil {
		return nil, err
	}
	// 锁集 + 需要广告解锁策略：前 10 集免费，11-30 需要激励视频解锁
	needAd := e.Episode > 10 && e.Episode <= 30
	unlockType := ""
	if needAd {
		unlockType = "reward_video"
	} else if e.Episode > 30 {
		unlockType = "vip"
	}
	return &EpisodePlay{
		Episode:      e.Episode,
		VideoURL:     s.videoURL(e.VideoKey),
		NextEpisode:  e.Episode + 1,
		NeedAdUnlock: needAd,
		UnlockType:   unlockType,
	}, nil
}

// CreateDramaInput CMS 上传入参
type CreateDramaInput struct {
	Title       string   `json:"title" binding:"required"`
	Description string   `json:"description"`
	Category    string   `json:"category"`
	Tags        []string `json:"tags"`
	Cover       string   `json:"cover"` // OSS key
	Episodes    []struct {
		Ep       int    `json:"ep" binding:"required"`
		Video    string `json:"video" binding:"required"` // OSS key
		Duration int    `json:"duration"`
	} `json:"episodes" binding:"required,dive"`
}

// Create CMS 新建剧集 + 批量分集
func (s *DramaService) Create(ctx context.Context, in CreateDramaInput) (int64, error) {
	drama := &model.Drama{
		Title:       in.Title,
		Description: in.Description,
		Cover:       in.Cover,
		Category:    in.Category,
		Tags:        strings.Join(in.Tags, ","),
		Status:      1,
		EpisodeCount: len(in.Episodes),
	}
	if err := s.repo.Create(ctx, drama); err != nil {
		return 0, err
	}
	eps := make([]model.Episode, 0, len(in.Episodes))
	for _, e := range in.Episodes {
		eps = append(eps, model.Episode{
			DramaID:  drama.ID,
			Episode:  e.Ep,
			Duration: e.Duration,
			VideoKey: e.Video,
			Locked:   e.Ep > 10,
		})
	}
	if err := s.repo.CreateEpisodes(ctx, eps); err != nil {
		return 0, err
	}
	return drama.ID, nil
}

// --- 内部工具 ------------------------------------------------------------

func (s *DramaService) coverURL(key string) string {
	if key == "" {
		return ""
	}
	if strings.HasPrefix(key, "http://") || strings.HasPrefix(key, "https://") {
		return key
	}
	if s.cdnBase == "" {
		return key
	}
	return s.cdnBase + "/" + strings.TrimLeft(key, "/")
}

func (s *DramaService) videoURL(key string) string {
	if key == "" {
		// Mock 默认公开视频，便于联调
		return "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
	}
	if strings.HasPrefix(key, "http://") || strings.HasPrefix(key, "https://") {
		return key
	}
	if s.cdnBase == "" {
		return "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/" + strings.TrimLeft(key, "/")
	}
	return s.cdnBase + "/" + strings.TrimLeft(key, "/")
}

func splitTags(raw string) []string {
	if raw == "" {
		return []string{}
	}
	parts := strings.Split(raw, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			out = append(out, p)
		}
	}
	return out
}
