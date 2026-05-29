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
    
    /// Force refresh — bypass cache
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
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
    }
}
