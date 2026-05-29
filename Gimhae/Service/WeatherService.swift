//
//  WeatherService.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine

// data.go.kr 기상청 단기예보 API
// Requires API key from data.go.kr (공공데이터포털 활용신청)

struct WeatherResponse: Codable {
    let temperature: String
    let condition: WeatherCondition
    let humidity: String
    let description: String
}

enum WeatherCondition: String, Codable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case snowy = "snowy"
    case overcast = "overcast"
    
    var iconName: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.sun.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .overcast: return "cloud.fill"
        }
    }
    
    var description: String {
        switch self {
        case .sunny: return "맑음"
        case .cloudy: return "구름 조금"
        case .rainy: return "비"
        case .snowy: return "눈"
        case .overcast: return "흐림"
        }
    }
}

final class WeatherService {
    static let shared = WeatherService()
    
    // TODO: Replace with actual data.go.kr API key
    // Register at https://www.data.go.kr/ → 기상청_단기예보 ((구)_동네예보) 조회서비스
    private let apiKey = ""
    private let baseURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
    
    // Gimhae grid coordinates for weather API (nx, ny)
    private let gimhaeNx = 95
    private let gimhaeNy = 77
    
    private let cache = CacheService.shared
    
    private init() {}
    
    /// Get current weather for Gimhae
    /// Note: Returns mock data until API key is configured
    func getCurrentWeather() -> AnyPublisher<WeatherResponse, Error> {
        guard !apiKey.isEmpty else {
            // Return mock data when API key is not configured
            return Just(WeatherResponse(
                temperature: "22°C",
                condition: .sunny,
                humidity: "55%",
                description: "맑음 (API 키 설정 필요)"
            ))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let baseDate = dateFormatter.string(from: Date())
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "serviceKey", value: apiKey),
            URLQueryItem(name: "numOfRows", value: "10"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "dataType", value: "JSON"),
            URLQueryItem(name: "base_date", value: baseDate),
            URLQueryItem(name: "base_time", value: "0600"),
            URLQueryItem(name: "nx", value: "\(gimhaeNx)"),
            URLQueryItem(name: "ny", value: "\(gimhaeNy)")
        ]
        
        guard let url = components.url else {
            return Fail(error: SimpleError(message: "Invalid weather URL"))
                .eraseToAnyPublisher()
        }
        
        let cacheKey = "weather_\(baseDate)"
        
        return cache.fetch(key: cacheKey, ttl: 3600) {
            URLSession.shared
                .dataTaskPublisher(for: url)
                .tryMap(\.data)
                .tryMap { _ in
                    // TODO: Parse actual response from data.go.kr
                    return WeatherResponse(
                        temperature: "22°C",
                        condition: .sunny,
                        humidity: "55%",
                        description: "맑음"
                    )
                }
                .eraseToAnyPublisher()
        }
    }
}
