-- AI短剧 APP 初始化 schema
-- 运行：mysql -u root -p < migrations/001_init.sql

CREATE DATABASE IF NOT EXISTS `aimj` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `aimj`;

-- 剧集主表
CREATE TABLE IF NOT EXISTS `drama` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(128) NOT NULL,
  `cover` VARCHAR(512) DEFAULT '',
  `description` TEXT,
  `category` VARCHAR(32) DEFAULT '',
  `tags` VARCHAR(256) DEFAULT '',
  `episode_count` INT DEFAULT 0,
  `updated_to` INT DEFAULT 0,
  `heat` BIGINT DEFAULT 0,
  `status` INT DEFAULT 1 COMMENT '1 上架 0 下架',
  `weight` INT DEFAULT 0 COMMENT '推荐权重',
  `created_at` DATETIME(3),
  `updated_at` DATETIME(3),
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`),
  KEY `idx_category` (`category`),
  KEY `idx_heat` (`heat`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 分集表
CREATE TABLE IF NOT EXISTS `episode` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `drama_id` BIGINT NOT NULL,
  `episode` INT NOT NULL,
  `duration` INT DEFAULT 0 COMMENT '秒',
  `video_key` VARCHAR(512) DEFAULT '' COMMENT 'OSS key',
  `locked` TINYINT(1) DEFAULT 0,
  `created_at` DATETIME(3),
  `updated_at` DATETIME(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_drama_ep` (`drama_id`, `episode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `phone` VARCHAR(32) DEFAULT '',
  `nickname` VARCHAR(64) DEFAULT '',
  `avatar` VARCHAR(512) DEFAULT '',
  `coins` BIGINT DEFAULT 0,
  `vip_until` DATETIME(3) DEFAULT NULL,
  `created_at` DATETIME(3),
  `updated_at` DATETIME(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 种子数据（与 client/lib/services/mock_data.dart 对齐）
INSERT INTO `drama` (`id`, `title`, `description`, `category`, `tags`, `episode_count`, `updated_to`, `heat`, `status`) VALUES
(1000, '重生归来：豪门逆袭', 'AI 生成短剧，每日更新，追更爽到飞起。', 'male',   '重生,逆袭',  60, 20, 100000,  1),
(1001, '战神不败：都市神王', 'AI 生成短剧，每日更新，追更爽到飞起。', 'female', '战神,都市',  60, 23, 187654,  1),
(1002, '赘婿崛起：复仇之路', 'AI 生成短剧，每日更新，追更爽到飞起。', 'male',   '赘婿,复仇',  60, 26, 275308,  1),
(1003, '甜宠总裁的心尖宝',    'AI 生成短剧，每日更新，追更爽到飞起。', 'female', '甜宠,总裁',  60, 29, 362962,  1),
(1004, '时间循环：重回高考',  'AI 生成短剧，每日更新，追更爽到飞起。', 'male',   '科幻,悬疑',  60, 32, 450616,  1),
(1005, '赛博都市：AI恋人',     'AI 生成短剧，每日更新，追更爽到飞起。', 'female', 'AI,恋爱',    60, 35, 538270,  1),
(1006, '医武双修：回到校园',  'AI 生成短剧，每日更新，追更爽到飞起。', 'male',   '医武,校园',  60, 38, 625924,  1),
(1007, '豪门千金归来',         'AI 生成短剧，每日更新，追更爽到飞起。', 'female', '豪门,女频',  60, 20, 713578,  1);
