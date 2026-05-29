//
//  FavoritesManager.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine

// MARK: - Favorite Item

struct FavoriteItem: Codable, Equatable, Identifiable {
    let id: String
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
