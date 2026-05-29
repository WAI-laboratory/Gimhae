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
