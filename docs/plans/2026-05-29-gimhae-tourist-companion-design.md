# 김해 여행 동반자 (Gimhae Travel Companion) — Feature Design

**Date:** 2026-05-29  
**Author:** Yongjun Lee  
**Status:** Approved  

---

## Vision

A content-centric tourist companion that helps visitors **discover, plan, and navigate** 김해's attractions, food, culture, and events — all powered by the city's own open data.

### Core Principles
- No sign-in required, frictionless from first launch
- Content-first discovery (cards, lists, curated feeds) with map as supporting tool
- Korean + English bilingual
- Hybrid caching so tourists can revisit saved content offline
- Open data powered — transparent, community-serving

### Target User Journey
1. Tourist arrives in 김해 (or plans a trip)
2. Opens app → sees curated highlights & current events
3. Browses by category (spots, food, heritage, festivals)
4. Taps into details (photos, hours, directions, nearby suggestions)
5. Saves favorites for their trip
6. Uses map when navigating between spots

---

## Tab Structure

| Tab | Name | Purpose |
|-----|------|---------|
| 1 | 홈 (Home) | Curated discovery feed — highlights, seasonal picks, nearby |
| 2 | 탐색 (Explore) | Browse by category — spots, food, heritage, stays, events |
| 3 | 지도 (Map) | Full map with all layers (existing + new overlays) |
| 4 | 내 여행 (My Trip) | Saved favorites, offline cached content, trip checklist |

Settings moves to a gear icon in the navigation bar.

---

## Tab 1: 홈 (Home) — Discovery Feed

### Sections (scrollable):

1. **"지금 김해에서는" (Happening Now)**
   - Active festivals, seasonal events, limited-time exhibits
   - Source: Festival API filtered by `sdate`/`edate`

2. **"추천 명소" (Recommended Spots)**
   - Editorially curated or algorithmically rotated tourist spots
   - Source: Tourism API (`tourinfo.do`)
   - Card-style with hero images

3. **"오늘의 공기" (Today's Air)**
   - Compact air quality summary
   - Source: Existing dust sensor API

4. **"김해 한눈에" (Gimhae at a Glance)**
   - Weather (data.go.kr weather API)
   - Fun city stat or fact

---

## Tab 2: 탐색 (Explore) — Browse by Category

### Categories (grid or horizontal scroll):

| Category | Data Source |
|----------|-------------|
| 🏛️ 관광지 (Attractions) | `tourinfo.do` API |
| 🍜 맛집 (Restaurants) | Gimhae restaurant API |
| 🎎 문화유산 (Heritage) | `asset.do` API + Firestore |
| 🎉 축제/행사 (Festivals) | `festival.do` API |
| 🏨 숙박 (Stays) | Gimhae accommodations API |
| 🅿️ 주차장 (Parking) | Smart City parking API |
| 📶 와이파이 (WiFi) | Smart City AP API |
| 🚲 자전거 (Bikes) | Existing bicycle API |

### List View (per category):
- Filterable by area/district
- Sort by: distance, name, popularity
- Each item: thumbnail, name, one-line description, distance badge

### Shared Detail View:
- Hero image carousel (FSPagerView)
- Name, category tag, address
- Operating hours, fees, parking info (where applicable)
- "지도에서 보기" (View on Map) → jumps to Tab 3
- "길찾기" (Get Directions) → opens Apple Maps / Naver Map
- "저장" (Save) → adds to My Trip (local storage)
- "이 근처 다른 곳" (Nearby) — other spots within 500m

---

## Tab 3: 지도 (Map) — All Layers

### Layer Toggle (bottom sheet or floating chips):

| Layer | Marker Style | Source |
|-------|-------------|--------|
| 관광지 (Attractions) | blue pin | Tourism API |
| 맛집 (Restaurants) | orange pin | Restaurant API |
| 문화유산 (Heritage) | brown pin | Heritage API |
| 축제 (Festivals) | purple pin | Festival API (active only) |
| 숙박 (Stays) | teal pin | Accommodations API |
| 주차장 (Parking) | gray | Smart City parking API |
| 와이파이 (WiFi) | green | Smart City AP API |
| 자전거 (Bikes) | yellow | Bicycle station API |
| 미세먼지 (Air) | colored circles | Dust sensor API |

### Interactions:
- Tap marker → bottom card preview (image, name, category, distance)
- Swipe card up → full detail view
- Cluster markers when zoomed out, expand on zoom in
- "내 주변" (Near Me) button → centers on user, shows radius
- Search bar at top → search across all categories

---

## Tab 4: 내 여행 (My Trip) — Personal Trip Space

No account required — everything stored locally.

### 저장한 곳 (Saved Places)
- List of favorited spots from any category
- Grouped by category tags
- Swipe to remove
- Tap to revisit detail (loads from cache if offline)

### 오프라인 저장 (Offline Cache)
- Auto-caches detail pages user has viewed
- Shows storage usage ("12개 저장됨 · 4.2MB")
- "모두 삭제" (Clear All) option

### 여행 체크리스트 (Trip Checklist)
- Editable checklist — user adds own items
- Pre-suggested: "수로왕릉 방문", "봉하마을 가기", "뒷골목 맛집 탐방"
- Toggle complete/incomplete

### 김해 방문 기록 (Visit Stats)
- "N곳 방문" — detail pages viewed
- "N개 카테고리 탐색" — categories explored

---

## Cross-Cutting Concerns

### Localization (Korean + English)
- All UI strings via `Localizable.strings` (ko, en)
- API content stays Korean (no English from city APIs)
- Language follows device setting, with in-app override
- Detail views: Korean content with English UI labels

### Hybrid Caching Strategy

| Layer | Cached | TTL |
|-------|--------|-----|
| API responses | JSON from all APIs | 1 hour |
| Images | Thumbnails + hero images | 7 days |
| Viewed details | Full detail page data | 30 days |
| Favorites | Saved places metadata | Permanent |

- `URLCache` + custom disk cache layer
- Stale-while-revalidate pattern
- Offline indicator: "오프라인 모드 · 저장된 데이터 표시 중"

### Architecture Evolution

| Current | Addition |
|---------|----------|
| Per-screen Core | Shared `AppState` for cross-tab data |
| Service → AnyPublisher | `CacheService` wrapper (cache → network → update) |
| Models per feature | Shared `Place` protocol for all location models |

```swift
protocol Place {
    var id: String { get }
    var name: String { get }
    var category: PlaceCategory { get }
    var coordinate: Coordinate { get }
    var thumbnailURL: String? { get }
    var images: [String] { get }
}
```

### Dependencies

| Package | Purpose |
|---------|---------|
| `Kingfisher` | Robust image caching |
| `CoreData` or `Realm` | Local persistence (favorites + cache) |
| `NMapsMap` (keep) | Map rendering |
| `SkeletonView` | Loading placeholders |
| `SnapKit` (keep) | Auto Layout |
| `CoreEngine` (keep) | State management |

---

## APIs

### Gimhae City APIs (existing + new)

| API | Endpoint |
|-----|----------|
| Tourism | `http://www.gimhae.go.kr/openapi/tour/tourinfo.do` |
| Festivals | `http://www.gimhae.go.kr/openapi/tour/festival.do` |
| Heritage | `http://www.gimhae.go.kr/openapi/tour/asset.do` |
| Restaurants | `http://www.gimhae.go.kr/openapi/tour/restaurant.do` (TBD) |
| Accommodations | `http://www.gimhae.go.kr/openapi/tour/accommodation.do` (TBD) |
| Dust Sensors | `http://smartcity.gimhae.go.kr/.../dustSensor` |
| Bicycle Stations | `http://smartcity.gimhae.go.kr/.../bicycleStation` |
| Parking Lots | `http://smartcity.gimhae.go.kr/.../parkingLot` |
| WiFi APs | `http://smartcity.gimhae.go.kr/.../ap` |

### data.go.kr APIs (new)

| API | Purpose |
|-----|---------|
| 기상청 단기예보 | Weather forecast for Home tab |
| 한국관광공사 관광정보 | English descriptions, richer data |
| 국토교통부 버스도착정보 | Bus arrivals near attractions |
| 문화재청 국가문화유산 | Enriched heritage details |
| 한국철도공사 열차시각표 | Train schedules ("김해 가는 법") |

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- Restructure to 4-tab layout
- Create shared `Place` protocol
- Build `CacheService` wrapper
- Set up `Localizable.strings` (ko/en)
- Add CoreData for local persistence
- Migrate existing map to Tab 3

### Phase 2: Explore Tab (Week 2)
- Integrate new APIs: Tourism, Restaurants, Accommodations, Parking
- Build category grid/list UI
- Build shared detail view
- Wire up "View on Map" → Tab 3
- Connect existing Festival + Heritage into Explore
- Wire up WiFi (already coded)

### Phase 3: Home Tab (Week 3)
- "Happening Now" — active festivals by date
- "Recommended Spots" — rotating featured places
- "Today's Air" — compact dust summary
- "Gimhae at a Glance" — weather + city stat
- Register data.go.kr API keys

### Phase 4: My Trip + Offline (Week 4)
- Favorites system (save/unsave)
- Offline cache layer
- Trip checklist
- Visit stats
- Offline mode indicator

### Phase 5: Polish + Enrich (Week 5+)
- data.go.kr: bus arrivals, train schedules, heritage
- "김해 가는 법" section
- Marker clustering
- Skeleton loading states
- Full English localization pass
- App Store preparation
