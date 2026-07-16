# 天梯服务 · 部署指南（Cloudflare Workers + D1，免费档）

纯荣誉榜。**我不能替你部署**——需要登录你自己的 Cloudflare 账号。下面 4 步，约 3 分钟。

## 为什么是 Cloudflare

免费档够用且不睡眠：Workers 10 万请求/天、D1 500 万行读/天 + 10 万行写/天。朋友几十人玩，用不到零头。不用信用卡。

## 部署（在本目录执行）

```bash
cd server/ladder

# 1. 登录（浏览器弹 OAuth，只有你能做）
npx wrangler login

# 2. 建数据库 → 把输出里的 database_id 填进 wrangler.toml
npx wrangler d1 create poker-ladder

# 3. 建表（远端）
npx wrangler d1 execute poker-ladder --remote --file=./schema.sql

# 4. 部署 → 记下输出的 https://poker-ladder.<你的子域>.workers.dev
npx wrangler deploy
```

## 接到游戏里

打开游戏 → ☰ → 规则/责任设置 → **天梯服务地址** 填上一步的 URL（不要带结尾斜杠）→ 保存。

想让**所有朋友**默认就能看到榜单（而不是各自去填）：把该 URL 写进 `index.html` 里 `var ladderURL='';` 的默认值，然后照常发布。

## 自测

```bash
curl https://poker-ladder.<你的子域>.workers.dev/health
# → {"ok":true,"service":"poker-ladder","honest":true}

curl https://poker-ladder.<你的子域>.workers.dev/board
# → {"ok":true,"board":[]}
```

## 接口

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/health` | 健康检查 |
| GET | `/board?limit=50` | 榜单（rp 降序） |
| POST | `/submit` | body `{id,nick,rp,hands}`，按 id upsert，返回最新榜单 |

## 积分口径

`rp = Σ(每手净额 ÷ 大盲 × 桌面等级系数)`，系数 L1 鱼 ×0.2 / L2 ×0.5 / L3 ×1.0 / L4 ×2.0 / L5 宗师 ×3.5（混合桌取在座 AI 的平均）。**虐鱼几乎不加分，赢宗师才值钱。**

## ⚠️ 诚实榜：已知且被接受的取舍

**分数是玩家浏览器本地算完上传的，服务端不校验真伪。** 任何人打开控制台就能提交任意分数。这是 2026-07-14 明确选择的取舍：朋友之间纯荣誉、不涉钱，先要能玩起来。

服务端只做基本卫生（昵称清洗防注入、数字合法性、字段限长），**这不是防作弊**。

将来真要开放给陌生人，需要按顺序补：
1. **手历哈希链校验**——把游戏已有的防篡改链一起传，服务端复算（挡随手改分，挡不住精心伪造）
2. **服务器权威发牌**——发牌和结算都在服务端（真防作弊，但基本等于重写游戏）

## 维护

```bash
npx wrangler d1 execute poker-ladder --remote --command="SELECT * FROM players ORDER BY rp DESC LIMIT 20"
npx wrangler d1 execute poker-ladder --remote --command="DELETE FROM players WHERE id='xxx'"   # 删除某人
npx wrangler tail poker-ladder                                                                  # 看实时日志
```
