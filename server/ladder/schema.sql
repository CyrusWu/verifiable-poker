-- 德州 AI 教练 · 天梯 D1 表结构 (v0.23 分级榜)
-- 每个难度一张榜:主键 (id, tier) —— 同一个人在每档各有一条成绩。
DROP TABLE IF EXISTS players;   -- v0.20 的单榜结构(rp 单列)已废弃;天梯从未部署过,无数据可迁

CREATE TABLE IF NOT EXISTS players (
  id      TEXT    NOT NULL,        -- 浏览器本地随机 ID(清缓存即丢失,得重来)
  tier    INTEGER NOT NULL,        -- 联赛档位 1-5(L1 鱼 … L5 宗师)
  nick    TEXT    NOT NULL,        -- 昵称(≤16,服务端已清洗)
  bb100   REAL    NOT NULL,        -- 榜内口径:每百手赢几个大盲(扑克标准胜率)
  hands   INTEGER NOT NULL,        -- 手数(满 30 才进榜,防小样本)
  updated INTEGER,                 -- epoch ms
  PRIMARY KEY (id, tier)
);
CREATE INDEX IF NOT EXISTS idx_tier_rank ON players(tier, bb100 DESC);
