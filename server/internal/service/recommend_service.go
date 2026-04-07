package service

import (
	"context"
	"sort"
	"strings"

	"github.com/aimj/server/internal/model"
	"github.com/aimj/server/internal/repo"
)

// RecommendService 推荐算法 V1
//
// 策略：
//  1. 取用户观看历史 → 提取偏好标签（频率加权）
//  2. 遍历全部在架剧集，计算匹配分 = 标签命中数 × 2 + 热度归一化分
//  3. 去掉已看剧集
//  4. 按分数倒序返回 top N
//  5. 未登录用户退化为热度排序
type RecommendService struct {
	dramaRepo repo.DramaRepo
	userRepo  repo.UserRepo
	cdnBase   string
}

func NewRecommendService(dr repo.DramaRepo, ur repo.UserRepo, cdnBase string) *RecommendService {
	return &RecommendService{dramaRepo: dr, userRepo: ur, cdnBase: cdnBase}
}

func (s *RecommendService) Recommend(ctx context.Context, userID int64, limit int) ([]DramaListItem, error) {
	if limit <= 0 {
		limit = 20
	}

	// 获取全部在架剧集
	all, err := s.dramaRepo.List(ctx, repo.ListDramaParams{Page: 1, PageSize: 200})
	if err != nil {
		return nil, err
	}

	// 未登录 → 纯热度
	if userID == 0 {
		return s.toItems(all.List, limit), nil
	}

	_ = s.cdnBase // suppress unused

	// 已看剧集 ID 集合
	watchedIDs, _ := s.userRepo.WatchedDramaIDs(ctx, userID)
	watchedSet := make(map[int64]bool, len(watchedIDs))
	for _, id := range watchedIDs {
		watchedSet[id] = true
	}

	// 提取偏好标签（从已看剧的 tags 统计频率）
	tagFreq := map[string]int{}
	for _, d := range all.List {
		if !watchedSet[d.ID] {
			continue
		}
		for _, t := range strings.Split(d.Tags, ",") {
			t = strings.TrimSpace(t)
			if t != "" {
				tagFreq[t]++
			}
		}
	}

	// 计算每部剧的推荐分
	type scored struct {
		drama repo.ListDramaParams
		item  DramaListItem
		score float64
	}

	// 找最大热度用于归一化
	var maxHeat int64 = 1
	for _, d := range all.List {
		if d.Heat > maxHeat {
			maxHeat = d.Heat
		}
	}

	var candidates []scored
	for _, d := range all.List {
		if watchedSet[d.ID] {
			continue // 去重已看
		}
		// 标签匹配分
		var tagScore float64
		for _, t := range strings.Split(d.Tags, ",") {
			t = strings.TrimSpace(t)
			if freq, ok := tagFreq[t]; ok {
				tagScore += float64(freq) * 2
			}
		}
		// 热度归一化（0~1）
		heatScore := float64(d.Heat) / float64(maxHeat)

		candidates = append(candidates, scored{
			item: DramaListItem{
				ID:           d.ID,
				Title:        d.Title,
				Cover:        d.Cover,
				Tags:         splitTags(d.Tags),
				EpisodeCount: d.EpisodeCount,
				UpdatedTo:    d.UpdatedTo,
				Heat:         d.Heat,
			},
			score: tagScore + heatScore,
		})
	}

	// 按分数倒序
	sort.Slice(candidates, func(i, j int) bool {
		return candidates[i].score > candidates[j].score
	})

	result := make([]DramaListItem, 0, limit)
	for i := 0; i < len(candidates) && i < limit; i++ {
		result = append(result, candidates[i].item)
	}

	// 如果推荐不够（新用户没历史），用热度补齐
	if len(result) < limit {
		for _, d := range all.List {
			if len(result) >= limit {
				break
			}
			if watchedSet[d.ID] {
				continue
			}
			found := false
			for _, r := range result {
				if r.ID == d.ID {
					found = true
					break
				}
			}
			if !found {
				result = append(result, DramaListItem{
					ID:           d.ID,
					Title:        d.Title,
					Cover:        d.Cover,
					Tags:         splitTags(d.Tags),
					EpisodeCount: d.EpisodeCount,
					UpdatedTo:    d.UpdatedTo,
					Heat:         d.Heat,
				})
			}
		}
	}

	return result, nil
}

func (s *RecommendService) toItems(dramas []model.Drama, limit int) []DramaListItem {
	result := make([]DramaListItem, 0, limit)
	for i := 0; i < len(dramas) && i < limit; i++ {
		d := dramas[i]
		result = append(result, DramaListItem{
			ID: d.ID, Title: d.Title, Cover: d.Cover,
			Tags: splitTags(d.Tags), EpisodeCount: d.EpisodeCount,
			UpdatedTo: d.UpdatedTo, Heat: d.Heat,
		})
	}
	return result
}
