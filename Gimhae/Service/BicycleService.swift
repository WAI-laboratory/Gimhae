import Foundation
import Combine

class BicycleService: Servicable {
    static let shared = BicycleService()
    typealias Model = BicycleResponse
    var url = URL(string: "http://smartcity.gimhae.go.kr/smart_tour/dashboard/api/publicData/location/bicycleStation")
}

class BicycleInOutSerivce: Servicable {
    static let shared = BicycleInOutSerivce()
    typealias Model = BicycleInOutResponse
    var url = URL(string: "http://smartcity.gimhae.go.kr/smart_tour/dashboard/api/publicData/inOut/bicycleStation")
}
