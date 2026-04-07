package service

import (
	"sync"
	"time"
)

// AnalyticsService 埋点聚合（内存版 MVP）
//
// 生产环境替换为 ClickHouse / BigQuery。
type AnalyticsService struct {
	mu     sync.RWMutex
	counts map[string]int64            // event -> total count
	daily  map[string]map[string]int64 // date -> event -> count
}

func NewAnalyticsService() *AnalyticsService {
	return &AnalyticsService{
		counts: make(map[string]int64),
		daily:  make(map[string]map[string]int64),
	}
}

// EventInput 单条埋点
type EventInput struct {
	Event  string         `json:"event" binding:"required"`
	Params map[string]any `json:"params"`
	TS     int64          `json:"ts"` // 客户端时间戳 ms（可选）
}

// BatchInput 批量上报
type BatchInput struct {
	Events []EventInput `json:"events" binding:"required,dive"`
}

// Record 写入埋点
func (s *AnalyticsService) Record(events []EventInput) {
	s.mu.Lock()
	defer s.mu.Unlock()
	today := time.Now().Format("2006-01-02")
	if s.daily[today] == nil {
		s.daily[today] = make(map[string]int64)
	}
	for _, e := range events {
		s.counts[e.Event]++
		s.daily[today][e.Event]++
	}
}

// AnalyticsSummary 看板数据
type AnalyticsSummary struct {
	Total   map[string]int64            `json:"total"`
	Daily   map[string]map[string]int64 `json:"daily"` // 最近 7 天
	Today   map[string]int64            `json:"today"`
	Metrics DerivedMetrics              `json:"metrics"`
}

// DerivedMetrics 衍生指标
type DerivedMetrics struct {
	CompletionRate   float64 `json:"completionRate"`   // 完播率 = episode_complete / episode_play
	AutoNextRate     float64 `json:"autoNextRate"`     // 连播率 = auto_next / episode_complete
	AdConversionRate float64 `json:"adConversionRate"` // 广告转化 = unlock_success / ad_reward_finish
}

// Summary 返回聚合数据
func (s *AnalyticsService) Summary() AnalyticsSummary {
	s.mu.RLock()
	defer s.mu.RUnlock()

	today := time.Now().Format("2006-01-02")

	// 复制总量
	total := make(map[string]int64, len(s.counts))
	for k, v := range s.counts {
		total[k] = v
	}

	// 复制今日
	todayData := make(map[string]int64)
	if d, ok := s.daily[today]; ok {
		for k, v := range d {
			todayData[k] = v
		}
	}

	// 最近 7 天
	daily := make(map[string]map[string]int64)
	for i := 0; i < 7; i++ {
		date := time.Now().AddDate(0, 0, -i).Format("2006-01-02")
		if d, ok := s.daily[date]; ok {
			dayMap := make(map[string]int64, len(d))
			for k, v := range d {
				dayMap[k] = v
			}
			daily[date] = dayMap
		}
	}

	// 衍生指标
	plays := total["episode_play"]
	completes := total["episode_complete"]
	autoNext := total["auto_next"]
	rewardFinish := total["ad_reward_finish"]
	unlockSuccess := total["unlock_success"]

	var metrics DerivedMetrics
	if plays > 0 {
		metrics.CompletionRate = float64(completes) / float64(plays)
	}
	if completes > 0 {
		metrics.AutoNextRate = float64(autoNext) / float64(completes)
	}
	if rewardFinish > 0 {
		metrics.AdConversionRate = float64(unlockSuccess) / float64(rewardFinish)
	}

	return AnalyticsSummary{
		Total:   total,
		Daily:   daily,
		Today:   todayData,
		Metrics: metrics,
	}
}
