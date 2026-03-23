# OmniFluxmindSkill

一个用于 OmniFluxmind 电商情报采集的 skill 项目。

当前只接入了 1 个能力：

- 爆款视频列表采集

## 目录结构

```text
OmniFluxmindSkill/
├── SKILL.md
├── README.md
├── agents/
│   └── openai.yaml
└── scripts/
    └── fetch_hot_videos.sh
```

## 当前接口

- `GET /api/insight/hot-videos`

默认请求地址：

```text
http://114.55.91.177/api/insight/hot-videos
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
  默认值：`http://114.55.91.177/hot-videos`

## 支持参数

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

## 脚本用法

直接执行：

```bash
./scripts/fetch_hot_videos.sh \
  --time-range all \
  --favorite-status ALL \
  --sort-by COMPREHENSIVE \
  --page 1 \
  --size 12
```

带类目：

```bash
./scripts/fetch_hot_videos.sh \
  --category mouse \
  --time-range all \
  --favorite-status ALL \
  --sort-by LIKE_DESC \
  --page 1 \
  --size 12
```

## 返回数据

接口返回包装结构：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 24,
    "list": []
  }
}
```

`data.list[]` 常见字段包括：

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

## 说明

- 详细 skill 描述见 `SKILL.md`
- 这个仓库当前只覆盖“爆款视频”能力
- 后续新增接口时，可以继续在 `scripts/` 下补脚本，并同步更新 `SKILL.md` 和本 README
