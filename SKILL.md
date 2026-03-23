---
name: OmniFluxmindSkill
description: Use this skill when the user wants to collect OmniFluxmind ecommerce intelligence from the OmniFluxmind API, especially hot videos, potential products, public leads, and competitor-account search results.
---

# OmniFluxmindSkill

Use this skill when the task is to collect, filter, or summarize ecommerce intelligence from OmniFluxmind.

Current scope covers:

- hot-video lists
- potential-product lists
- public-lead lists, meta, and overview
- competitor-account search by keyword

Supported category enum for all category-based OmniFluxmind interfaces:

- `keyboard`
- `mouse`
- `memory`
- `monitor`
- `dress`

## Required config

- `OMNIFLUXMIND_BASE_URL`
  Default: `http://114.55.91.177/api`
- `OMNIFLUXMIND_API_KEY`
  This must be the current `sid` cookie value. Treat it as the API key and send it as `Cookie: sid=<value>`.
  This value must be configured manually.
- `OMNIFLUXMIND_REFERER`
  Optional override. If unset, each bundled script uses the page path that matches its endpoint.

## Workflow

1. Confirm which OmniFluxmind dataset the user wants:
   - hot videos
   - potential products
   - public leads
   - competitor accounts
2. If the user wants ecommerce insight from a product link, first open the product page in a headless browser and inspect the page content.
3. Extract the most likely product category from the page.
4. Only continue with OmniFluxmind category-based APIs if the extracted category is one of:
   - `keyboard`
   - `mouse`
   - `memory`
   - `monitor`
   - `dress`
5. If the category is unsupported or cannot be determined reliably, stop before calling OmniFluxmind category-based APIs and explain the limitation.
6. Clarify filters if category, time range, sorting, scene type, intention status, or pagination is ambiguous.
7. Use the matching bundled script for raw collection.
8. Parse the wrapped JSON response.
9. Summarize the result in business terms instead of dumping raw JSON.
10. Convert Unix seconds such as `publishTime`, `crawlTime`, and `eventTime` when presenting dates.

## API summary

### 1. Hot videos

- Method: `GET`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/hot-videos`

Query parameters:

- `category` `string` optional
  Supported enum: `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
- `timeRange` `string` optional
  Observed values: `all`, `3d`, `7d`, `15d`
- `favoriteStatus` `string` optional
  `ALL`, `FAVORITED`, `UNFAVORITED`
- `sortBy` `string` optional
  `COMPREHENSIVE`, `LIKE_DESC`, `PUBLISH_TIME_DESC`, `SHARE_DESC`
- `page` `number` optional
  Default in current UI: `1`
- `size` `number` optional
  Default in current UI: `12`

Common `data.list[]` fields:

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

### 2. Potential products

- Method: `GET`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/potential-products`

Query parameters:

- `category` `string` optional
  Supported enum: `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
- `page` `number` optional
  Default: `1`
- `size` `number` optional
  Backend default: `10`
  Current frontend often uses `12`

Common `data.list[]` fields:

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

Notes:

- `gmvMin` and `gmvMax` are in fen.
- `salesMin` and `salesMax` are raw counts.

Admin collection endpoint:

- Method: `POST`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/potential-products/collect`
- Body:
  - `{}` to collect all categories
  - `{"category":"keyboard"}` to collect one category, where `category` must be one of `keyboard`, `mouse`, `memory`, `monitor`, `dress`
- Response:
  - one category: `{"category":"keyboard","count":12}`
  - all categories: `{"results":{"keyboard":12,"mouse":8}}`

### 3. Public leads

- Method: `GET`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/leads`

Query parameters:

- `category` `string` optional
  Supported enum: `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
- `platform` `string` optional
  Observed values in current UI: `douyin`, `kuaishou`, `xiaohongshu`
- `sceneType` `string` optional
  `comment`, `danmaku`
- `intentionLevel` `string` optional
  `HIGH`, `NONE`
- `followStatus` `string` optional
  `UNFOLLOWED`, `IN_PROGRESS`, `FOLLOWED`, `FAILED`
- `page` `number` optional
  Default: `1`
- `size` `number` optional
  Default: `10`

Common `data.list[]` fields:

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
- `followedEcomAccountId` optional
- `followedEcomAccountName` optional

Related read endpoints:

- `GET {OMNIFLUXMIND_BASE_URL}/insight/leads/meta`
  Returns `categoryOptions`, `searchSceneOptions`, and `collectSceneOptions`.
- `GET {OMNIFLUXMIND_BASE_URL}/insight/leads/overview`
  Query:
  - `category` optional. Supported enum: `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
  Returns `windowDays`, `totalLeads`, `intentLeads`, and `followedLeads`.

Admin collection endpoint:

- Method: `POST`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/leads/collect`
- Body:
  - `category` `string` optional
    Supported enum: `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
  - `collectType` `string` optional
    `all`, `comment`, `danmaku`
- Response:
  - all categories: `{"message":"采集任务已提交，后台执行中"}`
  - one category: `{"message":"采集任务已提交","category":"keyboard"}`

### 4. Competitor-account search

- Method: `POST`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/category-user-profiles`

Request body:

- `platform` `string` required
  Currently only `douyin` is supported.
- `keyword` `string` required
  Search keyword such as `键盘`, `鼠标`, `连衣裙`.

Common `data.list[]` fields:

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

Notes:

- Current service searches videos first, then returns up to 3 matched competitor profiles.
- Empty result is still a successful response with `data.list = []`.

## Shared headers

- `Accept: application/json, text/plain, */*`
- `Referer: {OMNIFLUXMIND_REFERER}` or the script default for that page
- `Cookie: sid={OMNIFLUXMIND_API_KEY}`

## Raw request examples

### Hot videos

```bash
export OMNIFLUXMIND_API_KEY="your-current-sid"

curl --get "${OMNIFLUXMIND_BASE_URL%/}/insight/hot-videos" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Referer: ${OMNIFLUXMIND_REFERER:-http://114.55.91.177/hot-videos}" \
  -H "Cookie: sid=${OMNIFLUXMIND_API_KEY}" \
  --data-urlencode "timeRange=all" \
  --data-urlencode "favoriteStatus=ALL" \
  --data-urlencode "sortBy=COMPREHENSIVE" \
  --data-urlencode "page=1" \
  --data-urlencode "size=12"
```

### Potential products

```bash
curl --get "${OMNIFLUXMIND_BASE_URL%/}/insight/potential-products" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Referer: ${OMNIFLUXMIND_REFERER:-http://114.55.91.177/potential-products}" \
  -H "Cookie: sid=${OMNIFLUXMIND_API_KEY}" \
  --data-urlencode "category=keyboard" \
  --data-urlencode "page=1" \
  --data-urlencode "size=12"
```

### Public leads

```bash
curl --get "${OMNIFLUXMIND_BASE_URL%/}/insight/leads" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Referer: ${OMNIFLUXMIND_REFERER:-http://114.55.91.177/leads}" \
  -H "Cookie: sid=${OMNIFLUXMIND_API_KEY}" \
  --data-urlencode "category=keyboard" \
  --data-urlencode "sceneType=comment" \
  --data-urlencode "intentionLevel=HIGH" \
  --data-urlencode "followStatus=UNFOLLOWED" \
  --data-urlencode "page=1" \
  --data-urlencode "size=10"
```

### Competitor accounts

```bash
curl "${OMNIFLUXMIND_BASE_URL%/}/insight/category-user-profiles" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Content-Type: application/json" \
  -H "Referer: ${OMNIFLUXMIND_REFERER:-http://114.55.91.177/category-user-profiles}" \
  -H "Cookie: sid=${OMNIFLUXMIND_API_KEY}" \
  --data '{"platform":"douyin","keyword":"键盘"}'
```

## Output expectations

When answering the user after collection:

- Prefer ranked summaries over dumping raw JSON.
- Include the applied filters or request body.
- For hot videos, highlight top creators, engagement, and recency.
- For potential products, highlight category concentration, price bands, and sales ranges.
- For public leads, highlight category, scene type, intention, and follow-up status.
- For competitor accounts, highlight follower scale, positioning, and repeated themes.
- Call out missing data or empty lists explicitly.
- If the API fails, report the HTTP or business error and suggest checking whether the `sid` token expired.

## Tooling

Use the bundled scripts:

```bash
scripts/fetch_hot_videos.sh --time-range all --favorite-status ALL --sort-by COMPREHENSIVE --page 1 --size 12
scripts/fetch_potential_products.sh --category keyboard --page 1 --size 12
scripts/collect_potential_products.sh --category keyboard
scripts/fetch_public_leads.sh --category keyboard --scene-type comment --intention-level HIGH --follow-status UNFOLLOWED --page 1 --size 10
scripts/fetch_public_lead_meta.sh
scripts/fetch_public_lead_overview.sh --category keyboard
scripts/collect_public_leads.sh --category keyboard --collect-type comment
scripts/query_category_user_profiles.sh --platform douyin --keyword "键盘"
```
