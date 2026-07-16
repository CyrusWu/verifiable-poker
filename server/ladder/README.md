# 天梯服务 · 部署指南（Cloudflare Workers + D1，免费档）

> v0.23 起为**分级榜**：每个难度一张榜，口径 BB/100，满 30 手上榜。

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

curl "https://poker-ladder.<你的子域>.workers.dev/board?tier=3"
# → {"ok":true,"tier":3,"board":[]}
```

## 接口

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/health` | 健康检查 |
| GET | `/board?tier=3&limit=50` | 该档榜单（bb100 降序，满 30 手） |
| POST | `/submit` | body `{id,nick,tier,bb100,hands}`，按 (id,tier) upsert，返回该档最新榜 |

## 积分口径

**每个难度一张榜**，榜内 `bb100 = 累计大盲净额 ÷ 手数 × 100`（扑克标准胜率口径），满 30 手才进榜（防小样本登顶）。

v0.20 曾用"等级系数"把各档折算到单榜，已废弃——系数是拍的，且刷 L1 的量能盖过打 L5。分榜后系数不再需要。

计分闸门（客户端）：只有「天梯模式 + 全桌同档 + 档位与所选联赛一致」才计分；休闲局、混合桌一律不计。

## ⚠️ 诚实榜：已知且被接受的取舍

**分数是玩家浏览器本地算完上传的，服务端不校验真伪。** 任何人打开控制台就能提交任意分数。这是 2026-07-14 明确选择的取舍：朋友之间纯荣誉、不涉钱，先要能玩起来。

服务端只做基本卫生（昵称清洗防注入、数字合法性、字段限长），**这不是防作弊**。

将来真要开放给陌生人，需要按顺序补：
1. **手历哈希链校验**——把游戏已有的防篡改链一起传，服务端复算（挡随手改分，挡不住精心伪造）
2. **服务器权威发牌**——发牌和结算都在服务端（真防作弊，但基本等于重写游戏）

## 维护

```bash
npx wrangler d1 execute poker-ladder --remote --command="SELECT * FROM players WHERE tier=3 ORDER BY bb100 DESC LIMIT 20"
npx wrangler d1 execute poker-ladder --remote --command="DELETE FROM players WHERE id='xxx'"   # 删除某人
npx wrangler tail poker-ladder                                                                  # 看实时日志
```
