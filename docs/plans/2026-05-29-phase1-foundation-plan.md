# Phase 1: Foundation — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure the Gimhae app from a 3-tab utility app to a 4-tab tourist companion foundation with shared protocols, caching infrastructure, localization, and local persistence.

**Architecture:** Extend existing CoreEngine Redux pattern with shared `Place` protocol, `CacheService` wrapper (stale-while-revalidate), and CoreData for local persistence. All existing features remain functional.

**Tech Stack:** Swift, UIKit, Combine, CoreEngine, SnapKit, AddThen, CoreData, NMapsMap

---

## Task 1: Add New Dependencies to Podfile

**Files:**
- Modify: `Podfile`

**Step 1: Update Podfile with new pods**

```ruby
# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Gimhae' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Gimhae

  # Architecture & Reactive
  pod 'CoreEngine'
  pod 'CombineCocoa'
  
  # UI
  pod 'SnapKit'
  pod 'AddThen'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'Cards', :git => 'https://github.com/sobabear/Cards.git', :commit => 'f9f0d3a929df075cc911151291ca33967853f7f5'
  pod 'FSPagerView'
  pod 'SkeletonView'
  
  # Maps
  pod 'NMapsMap'
  
  # Networking & Images
  pod 'Kingfisher'
  
  # Firebase
  pod 'FirebaseAnalytics'
  pod 'CodableFirebase'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  end
end
```

**Step 2: Install pods**

Run: `cd /Users/yonjun/Desktop/personal/iOS/Gimhae && pod install`

**Step 3: Commit**

```bash
git add Podfile Podfile.lock
git commit -m "deps: add Kingfisher and SkeletonView pods for Phase 1"
```

---

## Task 2: Create Shared Place Protocol & PlaceCategory Enum

**Files:**
- Create: `Gimhae/Model/Place.swift`

**Step 1: Create the Place protocol and category enum**

```swift
//
//  Place.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import CoreLocation

// MARK: - Place Category

enum PlaceCategory: String, CaseIterable, Codable {
    case attraction = "attraction"
    case restaurant = "restaurant"
    case heritage = "heritage"
    case festival = "festival"
    case accommodation = "accommodation"
    case parking = "parking"
    case wifi = "wifi"
    case bicycle = "bicycle"
    
    var title: String {
        switch self {
        case .attraction: return "관광지"
        case .restaurant: return "맛집"
        case .heritage: return "문화유산"
        case .festival: return "축제/행사"
        case .accommodation: return "숙박"
        case .parking: return "주차장"
        case .wifi: return "와이파이"
        case .bicycle: return "자전거"
        }
    }
    
    var titleEN: String {
        switch self {
        case .attraction: return "Attractions"
        case .restaurant: return "Restaurants"
        case .heritage: return "Heritage"
        case .festival: return "Festivals"
        case .accommodation: return "Stays"
        case .parking: return "Parking"
        case .wifi: return "WiFi"
        case .bicycle: return "Bikes"
        }
    }
    
    var iconName: String {
        switch self {
        case .attraction: return "building.columns"
        case .restaurant: return "fork.knife"
        case .heritage: return "theatermasks"
        case .festival: return "party.popper"
        case .accommodation: return "bed.double"
        case .parking: return "p.square"
        case .wifi: return "wifi"
        case .bicycle: return "bicycle"
        }
    }
}

// MARK: - Place Protocol

protocol Place {
    var placeId: String { get }
    var placeName: String { get }
    var placeCategory: PlaceCategory { get }
    var placeCoordinate: CLLocationCoordinate2D? { get }
    var placeThumbnailURL: String? { get }
    var placeImages: [String] { get }
    var placeAddress: String? { get }
    var placeSummary: String? { get }
}

extension Place {
    var placeThumbnailURL: String? {
        return placeImages.first
    }
    
    var placeSummary: String? {
        return nil
    }
}

// MARK: - Coordinate Helper

struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Tourism API Models

struct TourismResponse: Codable {
    var record_count: Int
    var pageunit: Int
    var page_count: Int
    var page: Int
    var results: [TourismSpot]
}

struct TourismSpot: Codable {
    var idx: Int
    var name: String
    var category: String
    var area: String
    var copy: String
    var manage: String
    var phone: String
    var homepage: String
    var content: String
    var fee: String
    var userhour: String
    var address: String
    var xposition: String
    var yposition: String
    var parking: String
    var images: [String]
}

extension TourismSpot: Place {
    var placeId: String { "tour_\(idx)" }
    var placeName: String { name }
    var placeCategory: PlaceCategory { .attraction }
    var placeCoordinate: CLLocationCoordinate2D? {
        guard let lat = Double(xposition), let lng = Double(yposition) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    var placeThumbnailURL: String? { images.first }
    var placeImages: [String] { images }
    var placeAddress: String? { address }
    var placeSummary: String? { copy }
}

// MARK: - Existing Model Conformance

extension Festival: Place {
    var placeId: String { "festival_\(idx)" }
    var placeName: String { name }
    var placeCategory: PlaceCategory { .festival }
    var placeCoordinate: CLLocationCoordinate2D? {
        guard let lat = Double(xposition), let lng = Double(yposition) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    var placeThumbnailURL: String? { images.first }
    var placeImages: [String] { images }
    var placeAddress: String? { address }
    var placeSummary: String? { copy }
}
```

**Step 2: Commit**

```bash
git add Gimhae/Model/Place.swift
git commit -m "feat: add Place protocol, PlaceCategory enum, and TourismSpot model"
```

---

## Task 3: Create CacheService (Stale-While-Revalidate)

**Files:**
- Create: `Gimhae/Service/CacheService.swift`

**Step 1: Create CacheService**

```swift
//
//  CacheService.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine

// MARK: - Cache Entry

struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let ttl: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
    
    var isStale: Bool {
        isExpired
    }
}

// MARK: - Cache Service

final class CacheService {
    static let shared = CacheService()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Default TTLs
    enum TTL {
        static let apiResponse: TimeInterval = 3600       // 1 hour
        static let images: TimeInterval = 604800          // 7 days
        static let viewedDetail: TimeInterval = 2592000   // 30 days
    }
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("GimhaeCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Public API
    
    /// Fetch with stale-while-revalidate strategy.
    /// Returns cached data immediately if available (even if stale),
    /// then fetches fresh data in background and updates cache.
    func fetch<T: Codable>(
        key: String,
        ttl: TimeInterval = TTL.apiResponse,
        network: @escaping () -> AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        
        let cached = loadFromDisk(key: key, type: T.self)
        
        if let cached = cached {
            if !cached.isStale {
                // Fresh cache — return immediately
                return Just(cached.data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                // Stale cache — return stale immediately, refresh in background
                let stalePublisher = Just(cached.data)
                    .setFailureType(to: Error.self)
                
                let refreshPublisher = network()
                    .handleEvents(receiveOutput: { [weak self] data in
                        self?.saveToDisk(key: key, data: data, ttl: ttl)
                    })
                
                return stalePublisher
                    .merge(with: refreshPublisher)
                    .eraseToAnyPublisher()
            }
        } else {
            // No cache — fetch from network
            return network()
                .handleEvents(receiveOutput: { [weak self] data in
                    self?.saveToDisk(key: key, data: data, ttl: ttl)
                })
                .eraseToAnyPublisher()
        }
    }
    
    /// Force refresh — bypass cache and fetch from network
    func refresh<T: Codable>(
        key: String,
        ttl: TimeInterval = TTL.apiResponse,
        network: @escaping () -> AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        return network()
            .handleEvents(receiveOutput: { [weak self] data in
                self?.saveToDisk(key: key, data: data, ttl: ttl)
            })
            .eraseToAnyPublisher()
    }
    
    /// Check if we have cached data (stale or fresh)
    func hasCachedData(key: String) -> Bool {
        let fileURL = cacheFileURL(for: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Clear all cache
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Clear specific cache entry
    func clear(key: String) {
        let fileURL = cacheFileURL(for: key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Get total cache size in bytes
    func totalCacheSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }
    
    /// Format cache size as human-readable string
    func formattedCacheSize() -> String {
        let bytes = totalCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Private
    
    private func cacheFileURL(for key: String) -> URL {
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return cacheDirectory.appendingPathComponent(sanitizedKey + ".cache")
    }
    
    private func saveToDisk<T: Codable>(key: String, data: T, ttl: TimeInterval) {
        let entry = CacheEntry(data: data, timestamp: Date(), ttl: ttl)
        let fileURL = cacheFileURL(for: key)
        
        do {
            let encoded = try encoder.encode(entry)
            try encoded.write(to: fileURL)
        } catch {
            print("⚠️ CacheService: Failed to save cache for key '\(key)': \(error)")
        }
    }
    
    private func loadFromDisk<T: Codable>(key: String, type: T.Type) -> CacheEntry<T>? {
        let fileURL = cacheFileURL(for: key)
        
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        do {
            let entry = try decoder.decode(CacheEntry<T>.self, from: data)
            return entry
        } catch {
            // Corrupted cache — remove it
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
    }
}
```

**Step 2: Commit**

```bash
git add Gimhae/Service/CacheService.swift
git commit -m "feat: add CacheService with stale-while-revalidate caching strategy"
```

---

## Task 4: Create FavoritesManager (Local Persistence with UserDefaults)

**Files:**
- Create: `Gimhae/Service/FavoritesManager.swift`

**Step 1: Create FavoritesManager**

```swift
//
//  FavoritesManager.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine

// MARK: - Favorite Item (lightweight reference)

struct FavoriteItem: Codable, Equatable, Identifiable {
    let id: String          // placeId
    let name: String
    let category: PlaceCategory
    let thumbnailURL: String?
    let address: String?
    let savedAt: Date
    
    init(from place: any Place) {
        self.id = place.placeId
        self.name = place.placeName
        self.category = place.placeCategory
        self.thumbnailURL = place.placeThumbnailURL
        self.address = place.placeAddress
        self.savedAt = Date()
    }
}

// MARK: - Favorites Manager

final class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let key = "gimhae_favorites"
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    @Published private(set) var favorites: [FavoriteItem] = []
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public API
    
    func isFavorite(placeId: String) -> Bool {
        favorites.contains(where: { $0.id == placeId })
    }
    
    func toggle(place: any Place) {
        if isFavorite(placeId: place.placeId) {
            remove(placeId: place.placeId)
        } else {
            add(place: place)
        }
    }
    
    func add(place: any Place) {
        guard !isFavorite(placeId: place.placeId) else { return }
        let item = FavoriteItem(from: place)
        favorites.insert(item, at: 0)
        saveFavorites()
    }
    
    func remove(placeId: String) {
        favorites.removeAll(where: { $0.id == placeId })
        saveFavorites()
    }
    
    func removeAll() {
        favorites.removeAll()
        saveFavorites()
    }
    
    var count: Int { favorites.count }
    
    func favorites(for category: PlaceCategory) -> [FavoriteItem] {
        favorites.filter { $0.category == category }
    }
    
    // MARK: - Private
    
    private func loadFavorites() {
        guard let data = defaults.data(forKey: key) else {
            favorites = []
            return
        }
        favorites = (try? decoder.decode([FavoriteItem].self, from: data)) ?? []
    }
    
    private func saveFavorites() {
        guard let data = try? encoder.encode(favorites) else { return }
        defaults.set(data, forKey: key)
    }
}
```

**Step 2: Commit**

```bash
git add Gimhae/Service/FavoritesManager.swift
git commit -m "feat: add FavoritesManager with local persistence via UserDefaults"
```

---

## Task 5: Create TourismService

**Files:**
- Create: `Gimhae/Service/TourismService.swift`

**Step 1: Create TourismService**

```swift
//
//  TourismService.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine

final class TourismService {
    static let shared = TourismService()
    
    private let baseURL = "http://www.gimhae.go.kr/openapi/tour/tourinfo.do"
    private let cache = CacheService.shared
    
    private init() {}
    
    func getTourismSpots(page: Int = 1, pageunit: Int = 50, name: String? = nil) -> AnyPublisher<TourismResponse, Error> {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageunit", value: "\(pageunit)")
        ]
        if let name = name {
            components.queryItems?.append(URLQueryItem(name: "name", value: name))
        }
        
        guard let url = components.url else {
            return Fail(error: SimpleError(message: "Invalid URL"))
                .eraseToAnyPublisher()
        }
        
        let cacheKey = "tourism_p\(page)_u\(pageunit)_\(name ?? "")"
        
        return cache.fetch(key: cacheKey) {
            URLSession.shared
                .dataTaskPublisher(for: url)
                .tryMap(\.data)
                .tryMap { data in
                    do {
                        return try JSONDecoder().decode(TourismResponse.self, from: data)
                    } catch {
                        throw DecodeFailedError(data: data, error: error)
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}
```

**Step 2: Commit**

```bash
git add Gimhae/Service/TourismService.swift
git commit -m "feat: add TourismService with cache integration for tourism spots API"
```

---

## Task 6: Set Up Localization (Localizable.strings)

**Files:**
- Create: `Gimhae/Resources/ko.lproj/Localizable.strings`
- Create: `Gimhae/Resources/en.lproj/Localizable.strings`
- Create: `Gimhae/Utills/String+Localized.swift`

**Step 1: Create Korean strings**

```
/* Tab Bar */
"tab.home" = "홈";
"tab.explore" = "탐색";
"tab.map" = "지도";
"tab.myTrip" = "내 여행";

/* Home */
"home.happeningNow" = "지금 김해에서는";
"home.recommended" = "추천 명소";
"home.todayAir" = "오늘의 공기";
"home.atAGlance" = "김해 한눈에";

/* Explore */
"explore.title" = "탐색";
"explore.attraction" = "관광지";
"explore.restaurant" = "맛집";
"explore.heritage" = "문화유산";
"explore.festival" = "축제/행사";
"explore.accommodation" = "숙박";
"explore.parking" = "주차장";
"explore.wifi" = "와이파이";
"explore.bicycle" = "자전거";

/* Detail */
"detail.viewOnMap" = "지도에서 보기";
"detail.getDirections" = "길찾기";
"detail.save" = "저장";
"detail.saved" = "저장됨";
"detail.nearby" = "이 근처 다른 곳";
"detail.hours" = "운영 시간";
"detail.fee" = "이용 요금";
"detail.address" = "주소";
"detail.phone" = "전화";
"detail.parking" = "주차";

/* Map */
"map.title" = "지도";
"map.nearMe" = "내 주변";
"map.search" = "장소 검색";

/* My Trip */
"myTrip.title" = "내 여행";
"myTrip.savedPlaces" = "저장한 곳";
"myTrip.offlineCache" = "오프라인 저장";
"myTrip.checklist" = "여행 체크리스트";
"myTrip.visitStats" = "김해 방문 기록";
"myTrip.clearAll" = "모두 삭제";
"myTrip.placesVisited" = "%d곳 방문";
"myTrip.categoriesExplored" = "%d개 카테고리 탐색";

/* Common */
"common.offline" = "오프라인 모드 · 저장된 데이터 표시 중";
"common.loading" = "불러오는 중...";
"common.error" = "오류가 발생했습니다";
"common.retry" = "다시 시도";
"common.noResults" = "결과가 없습니다";
"common.settings" = "설정";

/* Settings */
"settings.title" = "설정";
"settings.language" = "언어";
"settings.clearCache" = "캐시 삭제";
"settings.version" = "버전";
"settings.feedback" = "기능 제안";
```

**Step 2: Create English strings**

```
/* Tab Bar */
"tab.home" = "Home";
"tab.explore" = "Explore";
"tab.map" = "Map";
"tab.myTrip" = "My Trip";

/* Home */
"home.happeningNow" = "Happening Now in Gimhae";
"home.recommended" = "Recommended Spots";
"home.todayAir" = "Today's Air";
"home.atAGlance" = "Gimhae at a Glance";

/* Explore */
"explore.title" = "Explore";
"explore.attraction" = "Attractions";
"explore.restaurant" = "Restaurants";
"explore.heritage" = "Heritage";
"explore.festival" = "Festivals";
"explore.accommodation" = "Stays";
"explore.parking" = "Parking";
"explore.wifi" = "WiFi";
"explore.bicycle" = "Bikes";

/* Detail */
"detail.viewOnMap" = "View on Map";
"detail.getDirections" = "Get Directions";
"detail.save" = "Save";
"detail.saved" = "Saved";
"detail.nearby" = "Nearby Places";
"detail.hours" = "Hours";
"detail.fee" = "Fee";
"detail.address" = "Address";
"detail.phone" = "Phone";
"detail.parking" = "Parking";

/* Map */
"map.title" = "Map";
"map.nearMe" = "Near Me";
"map.search" = "Search places";

/* My Trip */
"myTrip.title" = "My Trip";
"myTrip.savedPlaces" = "Saved Places";
"myTrip.offlineCache" = "Offline Cache";
"myTrip.checklist" = "Trip Checklist";
"myTrip.visitStats" = "Visit History";
"myTrip.clearAll" = "Clear All";
"myTrip.placesVisited" = "%d places visited";
"myTrip.categoriesExplored" = "%d categories explored";

/* Common */
"common.offline" = "Offline Mode · Showing saved data";
"common.loading" = "Loading...";
"common.error" = "Something went wrong";
"common.retry" = "Retry";
"common.noResults" = "No results";
"common.settings" = "Settings";

/* Settings */
"settings.title" = "Settings";
"settings.language" = "Language";
"settings.clearCache" = "Clear Cache";
"settings.version" = "Version";
"settings.feedback" = "Request a Feature";
```

**Step 3: Create localization helper**

```swift
//
//  String+Localized.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
```

**Step 4: Commit**

```bash
git add Gimhae/Resources/ Gimhae/Utills/String+Localized.swift
git commit -m "feat: add Korean + English localization with String+Localized helper"
```

---

## Task 7: Restructure to 4-Tab Layout

**Files:**
- Modify: `Gimhae/UI/BaseTabbarController.swift`
- Create: `Gimhae/UI/Home/HomeViewController.swift`
- Create: `Gimhae/UI/Home/HomeCore.swift`
- Create: `Gimhae/UI/Explore/ExploreViewController.swift`
- Create: `Gimhae/UI/Explore/ExploreCore.swift`
- Create: `Gimhae/UI/MyTrip/MyTripViewController.swift`
- Create: `Gimhae/UI/MyTrip/MyTripCore.swift`

**Step 1: Create HomeViewController (placeholder)**

```swift
//
//  HomeViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class HomeViewController: BaseViewController {
    
    private let core = HomeCore()
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 24
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "김해"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
    }
    
    private lazy var subtitleLabel = UILabel().then {
        $0.text = "tab.home".localized
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "tab.home".localized
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 40, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
        
        // Placeholder sections
        let sections = [
            "home.happeningNow".localized,
            "home.recommended".localized,
            "home.todayAir".localized,
            "home.atAGlance".localized
        ]
        
        for section in sections {
            let sectionView = makeSectionPlaceholder(title: section)
            contentStack.addArrangedSubview(sectionView)
        }
    }
    
    private func makeSectionPlaceholder(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let comingSoon = UILabel()
        comingSoon.text = "Coming in Phase 3"
        comingSoon.font = .systemFont(ofSize: 13, weight: .regular)
        comingSoon.textColor = .tertiaryLabel
        
        container.addSubview(label)
        container.addSubview(comingSoon)
        
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        comingSoon.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        container.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        
        return container
    }
    
    private func bindState() {
        // Will be implemented in Phase 3
    }
}
```

**Step 2: Create HomeCore (placeholder)**

```swift
//
//  HomeCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class HomeCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case loaded
    }
    
    struct State {
        var isLoading: Bool = false
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case .loaded:
            newState.isLoading = false
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ HomeCore: \(error)")
    }
}
```

**Step 3: Create ExploreViewController (placeholder with category grid)**

```swift
//
//  ExploreViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class ExploreViewController: BaseViewController {
    
    private let core = ExploreCore()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        return cv
    }()
    
    private let categories = PlaceCategory.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "tab.explore".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        cell.configure(with: categories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20 - 20 - 12) / 2
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        // TODO: Phase 2 — push category list view
        print("Selected: \(category.title)")
    }
}

// MARK: - Category Cell

final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.size.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom).offset(8)
        }
    }
    
    func configure(with category: PlaceCategory) {
        iconView.image = UIImage(systemName: category.iconName)
        titleLabel.text = category.title
    }
}
```

**Step 4: Create ExploreCore (placeholder)**

```swift
//
//  ExploreCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class ExploreCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case setCategory(PlaceCategory)
        case loaded
    }
    
    struct State {
        var selectedCategory: PlaceCategory? = nil
        var isLoading: Bool = false
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case let .setCategory(category):
            newState.selectedCategory = category
        case .loaded:
            newState.isLoading = false
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ ExploreCore: \(error)")
    }
}
```

**Step 5: Create MyTripViewController (placeholder)**

```swift
//
//  MyTripViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class MyTripViewController: BaseViewController {
    
    private let core = MyTripCore()
    private let favoritesManager = FavoritesManager.shared
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 24
    }
    
    private lazy var emptyLabel = UILabel().then {
        $0.text = "저장한 장소가 없습니다\n탐색에서 마음에 드는 장소를 저장해보세요"
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "tab.myTrip".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 40, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
        
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    private func updateUI() {
        let hasFavorites = favoritesManager.count > 0
        emptyLabel.isHidden = hasFavorites
        scrollView.isHidden = !hasFavorites
        
        // TODO: Phase 4 — full implementation
    }
    
    private func bindState() {
        favoritesManager.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &subscription)
    }
}
```

**Step 6: Create MyTripCore (placeholder)**

```swift
//
//  MyTripCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class MyTripCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case loaded
    }
    
    struct State {
        var isLoading: Bool = false
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case .loaded:
            newState.isLoading = false
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ MyTripCore: \(error)")
    }
}
```

**Step 7: Update BaseTabBarController to 4 tabs**

Replace the full content of `BaseTabbarController.swift` with:

```swift
import UIKit
import Combine

final class BaseTabBarController: UITabBarController {
    private var subscription = Set<AnyCancellable>()
    
    let homeVC = HomeViewController()
    let exploreVC = ExploreViewController()
    let mainVC = MainViewController()
    let myTripVC = MyTripViewController()
    
    private var previousIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateTabBar()
    }
    
    private func initView() {
        delegate = self

        // MARK: - Home (홈)
        let homeSelected = UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let homeUnselected = UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        homeVC.tabBarItem = UITabBarItem(title: "tab.home".localized, image: homeUnselected, selectedImage: homeSelected)
        
        // MARK: - Explore (탐색)
        let exploreSelected = UIImage(systemName: "safari.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let exploreUnselected = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        exploreVC.tabBarItem = UITabBarItem(title: "tab.explore".localized, image: exploreUnselected, selectedImage: exploreSelected)
        
        // MARK: - Map (지도)
        let mapSelected = UIImage(systemName: "map.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let mapUnselected = UIImage(systemName: "map", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        mainVC.tabBarItem = UITabBarItem(title: "tab.map".localized, image: mapUnselected, selectedImage: mapSelected)
        
        // MARK: - My Trip (내 여행)
        let tripSelected = UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let tripUnselected = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        myTripVC.tabBarItem = UITabBarItem(title: "tab.myTrip".localized, image: tripUnselected, selectedImage: tripSelected)
        
        self.viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: exploreVC),
            UINavigationController(rootViewController: mainVC),
            UINavigationController(rootViewController: myTripVC),
        ]
    }
    
    private func updateTabBar(color: UIColor = .label) {
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .secondarySystemBackground
        tabBar.tintColor = userInterfaceStyle == .light ? .black : .white
        tabBar.unselectedItemTintColor = .secondaryLabel
        
        tabBar.layer.shadowColor = color.cgColor
        tabBar.layer.shadowOpacity = 0.08
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.setNeedsDisplay()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTabBar()
    }
    
    func changeTab(selectedIndex: Int) {
        dismissAllViewControllers()
        popAllViewControllers()
        self.selectedIndex = selectedIndex
        self.previousIndex = self.selectedIndex
    }
    
    private func dismissAllViewControllers(animated: Bool = false) {
        if let navigationController = selectedViewController as? UINavigationController {
            navigationController.dismiss(animated: animated, completion: nil)
        }
    }

    private func popAllViewControllers() {
        for viewController in viewControllers ?? [UIViewController]() {
            if let navigationController = viewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController is MainViewController) {
            tabBar.layer.shadowColor = UIColor.clear.cgColor
        } else {
            tabBar.layer.shadowColor = UIColor.quaternaryLabel.cgColor
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
```

**Step 8: Commit**

```bash
git add Gimhae/UI/
git commit -m "feat: restructure to 4-tab layout (Home, Explore, Map, My Trip)"
```

---

## Task 8: Add Settings Gear Button to Navigation

**Files:**
- Modify: `Gimhae/UI/Home/HomeViewController.swift` (add settings button)

**Step 1: Add settings nav bar button to HomeViewController**

Add to `setupUI()` after setting the title:

```swift
let settingsButton = UIBarButtonItem(
    image: UIImage(systemName: "gearshape"),
    style: .plain,
    target: self,
    action: #selector(openSettings)
)
navigationItem.rightBarButtonItem = settingsButton
```

Add method:

```swift
@objc private func openSettings() {
    let settingsVC = SettingViewController()
    navigationController?.pushViewController(settingsVC, animated: true)
}
```

**Step 2: Commit**

```bash
git add Gimhae/UI/Home/HomeViewController.swift
git commit -m "feat: add settings gear button to Home navigation bar"
```

---

## Task 9: Verify Build & Final Commit

**Step 1: Open workspace and verify build**

Run: `cd /Users/yonjun/Desktop/personal/iOS/Gimhae && xcodebuild -workspace Gimhae.xcworkspace -scheme Gimhae -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED

**Step 2: Fix any build errors if present**

**Step 3: Final commit (if fixes were needed)**

```bash
git add -A
git commit -m "fix: resolve build errors from Phase 1 foundation restructure"
```

---

## Summary

After completing all tasks, the app will have:
- ✅ 4-tab layout: 홈 · 탐색 · 지도 · 내 여행
- ✅ Shared `Place` protocol for all location-based models
- ✅ `CacheService` with stale-while-revalidate strategy
- ✅ `FavoritesManager` with local UserDefaults persistence
- ✅ `TourismService` integrated with caching
- ✅ Korean + English localization infrastructure
- ✅ Placeholder UIs for all new tabs (ready for Phase 2 content)
- ✅ Existing map functionality preserved in Tab 3
- ✅ Settings accessible via gear icon from Home
- ✅ New pods: Kingfisher, SkeletonView
