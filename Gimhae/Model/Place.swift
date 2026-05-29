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

// MARK: - Festival + Place Conformance

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
