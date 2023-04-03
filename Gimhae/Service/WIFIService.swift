import Foundation
import Combine

class WIFIService: Servicable {
    typealias Model = WIFIResponse
    var url = URL(string: "http://smartcity.gimhae.go.kr/smart_tour/dashboard/api/publicData/location/ap")
}

