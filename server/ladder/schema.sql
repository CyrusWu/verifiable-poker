-- 可验证德州扑克 · 天梯 D1 表结构
CREATE TABLE IF NOT EXISTS players (
  id      TEXT PRIMARY KEY,          -- 浏览器本地随机 ID(丢了就重来)
  nick    TEXT NOT NULL,             -- 昵称(≤16,服务端已清洗)
  rp      INTEGER NOT NULL DEFAULT 0,-- 天梯分 = Σ(每手净额/大盲 × 桌面等级系数)
  hands   INTEGER NOT NULL DEFAULT 0,
  updated INTEGER                    -- epoch ms
);
CREATE INDEX IF NOT EXISTS idx_players_rp ON players(rp DESC);
