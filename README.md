# OmniFluxmindSkill

一个用于 OmniFluxmind 电商情报采集的 skill 项目。

当前接入了 4 组能力：

- 爆款视频列表采集
- 潜力爆品列表与采集触发
- 公域线索列表、元信息、总览与采集触发
- 竞对账号关键词搜索

## 目录结构

```text
OmniFluxmindSkill/
├── SKILL.md
├── README.md
├── agents/
│   └── openai.yaml
└── scripts/
    ├── collect_potential_products.sh
    ├── collect_public_leads.sh
    ├── fetch_hot_videos.sh
    ├── fetch_potential_products.sh
    ├── fetch_public_lead_meta.sh
    ├── fetch_public_lead_overview.sh
    ├── fetch_public_leads.sh
    └── query_category_user_profiles.sh
```

## 当前接口

- `GET /api/insight/hot-videos`
- `GET /api/insight/potential-products`
- `POST /api/insight/potential-products/collect`
- `GET /api/insight/leads`
- `GET /api/insight/leads/meta`
- `GET /api/insight/leads/overview`
- `POST /api/insight/leads/collect`
- `POST /api/insight/category-user-profiles`

默认请求地址：

```text
http://114.55.91.177/api
```

## 认证方式

接口通过 Cookie 中的 `sid` 鉴权。

请手动配置 API key：

```bash
export OMNIFLUXMIND_API_KEY="你的最新sid"
```

## 环境变量

- `OMNIFLUXMIND_BASE_URL`
  默认值：`http://114.55.91.177/api`
- `OMNIFLUXMIND_API_KEY`
  无默认值，需手动配置
- `OMNIFLUXMIND_REFERER`
  可选覆盖；如果不传，每个脚本会使用对应页面的默认 Referer

## 爆款视频参数

- `category`
  类目编码，可选
- `timeRange`
  当前前端观察到支持：
  `all`、`3d`、`7d`、`15d`
- `favoriteStatus`
  支持：
  `ALL`、`FAVORITED`、`UNFAVORITED`
- `sortBy`
  支持：
  `COMPREHENSIVE`、`LIKE_DESC`、`PUBLISH_TIME_DESC`、`SHARE_DESC`
- `page`
  页码
- `size`
  每页数量

常见返回字段：

- `id`
- `title`
- `authorName`
- `platform`
- `platformPostId`
- `videoUrl`
- `likeCount`
- `commentCount`
- `collectCount`
- `shareCount`
- `coverUrl`
- `videoDna`
- `publishTime`
- `crawlTime`
- `category`
- `favorite`

## 潜力爆品参数

- `category`
  类目编码，可选
- `page`
  页码，默认 `1`
- `size`
  每页数量，后端默认 `10`

常见返回字段：

- `id`
- `platform`
- `platformProductId`
- `productName`
- `productImage`
- `productUrl`
- `category`
- `gmvMin`
- `gmvMax`
- `salesMin`
- `salesMax`
- `crawlTime`
- `createTime`
- `updateTime`

说明：

- `gmvMin` / `gmvMax` 单位为分
- `POST /insight/potential-products/collect` 支持空 body 全量采集，或传 `category` 单类目采集

## 公域线索参数

- `category`
  类目编码，可选
- `platform`
  平台，可选，前端当前使用：
  `douyin`、`kuaishou`、`xiaohongshu`
- `sceneType`
  场景，可选：
  `comment`、`danmaku`
- `intentionLevel`
  意向等级，可选：
  `HIGH`、`NONE`
- `followStatus`
  跟进状态，可选：
  `UNFOLLOWED`、`IN_PROGRESS`、`FOLLOWED`、`FAILED`
- `page`
  页码，默认 `1`
- `size`
  每页数量，默认 `10`

常见返回字段：

- `id`
- `itemId`
- `leadKey`
- `platform`
- `sceneType`
- `category`
- `actorName`
- `actorSecUid`
- `actorAvatar`
- `actorProfileUrl`
- `contentText`
- `intentionLevel`
- `sourceTitle`
- `sourceAvatar`
- `sourceId`
- `leadUrl`
- `eventTime`
- `crawlTime`
- `followStatus`
- `followedEcomAccountId`
- `followedEcomAccountName`

相关读取接口：

- `GET /api/insight/leads/meta`
  返回 `categoryOptions`、`searchSceneOptions`、`collectSceneOptions`
- `GET /api/insight/leads/overview`
  返回 `windowDays`、`totalLeads`、`intentLeads`、`followedLeads`

采集触发接口：

- `POST /api/insight/leads/collect`
- body 支持：
  - `category` 可选
  - `collectType` 可选，支持 `all`、`comment`、`danmaku`

## 竞对账号搜索参数

- `platform`
  必填，当前仅支持 `douyin`
- `keyword`
  必填，例如：`键盘`、`鼠标`、`连衣裙`

常见返回字段：

- `platform`
- `keyword`
- `secUid`
- `nickname`
- `avatarUrl`
- `uniqueId`
- `signature`
- `followerCount`
- `videoTitle`
- `videoAuthorName`

说明：

- 当前服务会先搜视频，再提取竞对作者资料
- 一次通常返回最多 3 个竞对账号

## 脚本用法

爆款视频：

```bash
./scripts/fetch_hot_videos.sh \
  --time-range all \
  --favorite-status ALL \
  --sort-by COMPREHENSIVE \
  --page 1 \
  --size 12
```

潜力爆品列表：

```bash
./scripts/fetch_potential_products.sh \
  --category keyboard \
  --page 1 \
  --size 12
```

触发潜力爆品采集：

```bash
./scripts/collect_potential_products.sh --category keyboard
```

公域线索列表：

```bash
./scripts/fetch_public_leads.sh \
  --category keyboard \
  --scene-type comment \
  --intention-level HIGH \
  --follow-status UNFOLLOWED \
  --page 1 \
  --size 10
```

公域线索元信息和总览：

```bash
./scripts/fetch_public_lead_meta.sh
./scripts/fetch_public_lead_overview.sh --category keyboard
```

触发公域线索采集：

```bash
./scripts/collect_public_leads.sh \
  --category keyboard \
  --collect-type comment
```

按关键词查询竞对账号：

```bash
./scripts/query_category_user_profiles.sh \
  --platform douyin \
  --keyword "键盘"
```

## 返回数据

接口返回包装结构通常为：

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

读取类接口一般都返回：

- `code`
  业务状态码，`0` 为成功
- `message`
  提示信息
- `data`
  业务数据

分页类读取接口的 `data` 常见为：

- `total`
- `list`

## 说明

- 详细 skill 描述见 `SKILL.md`
- 这个仓库当前覆盖爆款视频、潜力爆品、公域线索、竞对账号搜索
- 所有脚本都依赖手动配置的 `OMNIFLUXMIND_API_KEY`
