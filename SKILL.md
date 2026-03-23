name: OmniFluxmindSkill
description: Use this skill when the user wants to collect OmniFluxmind ecommerce intelligence, especially hot-video lists, ranking filters, and video metadata from the OmniFluxmind local API.
---

# OmniFluxmindSkill

Use this skill when the task is to collect, filter, or summarize ecommerce intelligence from OmniFluxmind.

Current scope: only the hot-video list API is covered.

## Required config

- `OMNIFLUXMIND_BASE_URL`
  Default: `http://114.55.91.177/api`
- `OMNIFLUXMIND_API_KEY`
  This must be the current `sid` cookie value. Treat it as the API key and send it as `Cookie: sid=<value>`.
  This value must be configured manually.
- `OMNIFLUXMIND_REFERER`
  Default: `http://114.55.91.177/hot-videos`

## Workflow

1. Confirm the user's filter intent if category, time range, favorite filter, sorting, or pagination is ambiguous.
2. Call `scripts/fetch_hot_videos.sh` for raw data collection.
3. Parse the JSON response.
4. Summarize the results in business terms:
   - which videos rank highest
   - which creators appear repeatedly
   - engagement patterns
   - which categories or platforms dominate
5. Convert `publishTime` and `crawlTime` from Unix seconds when presenting dates.

## API

### Endpoint

- Method: `GET`
- URL: `{OMNIFLUXMIND_BASE_URL}/insight/hot-videos`

### Required headers

- `Accept: application/json, text/plain, */*`
- `Referer: {OMNIFLUXMIND_REFERER}`
- `Cookie: sid={OMNIFLUXMIND_API_KEY}`

### Query parameters

- `category` `string` optional
  Category code. Observed examples include `keyboard`, `mouse`, `memory`, `monitor`, `dress`.
- `timeRange` `string` optional
  Supported values observed in current frontend:
  `all`, `3d`, `7d`, `15d`
  Older interface docs also mention `30d`; treat it as possible but verify if behavior matters.
- `favoriteStatus` `string` optional
  Supported values:
  `ALL`, `FAVORITED`, `UNFAVORITED`
- `sortBy` `string` optional
  Supported values:
  `COMPREHENSIVE`, `LIKE_DESC`, `PUBLISH_TIME_DESC`, `SHARE_DESC`
- `page` `number` optional
  Default in current UI: `1`
- `size` `number` optional
  Default in current UI: `12`

### Raw request example

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

### Response shape

Expect a wrapped response in this shape:

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 24,
    "list": [
      {
        "id": 33,
        "title": "罗技鼠标横评",
        "authorName": "外设测评站",
        "platform": "douyin",
        "platformPostId": "7512345678901234567",
        "videoUrl": "https://www.douyin.com/video/7512345678901234567",
        "likeCount": 52341,
        "commentCount": 1820,
        "collectCount": 932,
        "shareCount": 251,
        "coverUrl": "https://example.com/cover.jpg",
        "videoDna": "这类视频的核心成功点在于...",
        "publishTime": 1773651000,
        "crawlTime": 1773715200,
        "category": "mouse",
        "favorite": true
      }
    ]
  }
}
```

### Response fields

- `code` `number`
  Business status code. `0` means success.
- `message` `string`
  Status message.
- `data.total` `number`
  Total matched records.
- `data.list` `array`
  Current page records.

Each `data.list[]` item may contain:

- `id` `number`
- `title` `string`
- `authorName` `string`
- `platform` `string`
- `platformPostId` `string`
- `videoUrl` `string`
- `likeCount` `number`
- `commentCount` `number`
- `collectCount` `number`
- `shareCount` `number`
- `coverUrl` `string`
- `videoDna` `string`
- `publishTime` `number`
  Unix seconds
- `crawlTime` `number`
  Unix seconds
- `category` `string`
- `favorite` `boolean`
  Observed in current UI responses; treat as optional

## Output expectations

When answering the user after collection:

- Prefer ranked summaries over dumping raw JSON.
- Include the applied filters.
- Highlight top videos by likes, shares, and recency when useful.
- Call out missing data or empty lists explicitly.
- If the API fails, report the HTTP or business error and suggest checking whether the `sid` token expired.

## Tooling

Use the bundled script:

```bash
scripts/fetch_hot_videos.sh --time-range all --favorite-status ALL --sort-by COMPREHENSIVE --page 1 --size 12
```
