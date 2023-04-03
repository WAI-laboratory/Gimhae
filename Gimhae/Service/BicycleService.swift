import Foundation
import Combine

class BicycleService: Servicable {
    typealias Model = BicycleResponse
    var url = URL(string: "http://smartcity.gimhae.go.kr/smart_tour/dashboard/api/publicData/location/bicycleStation")
}
