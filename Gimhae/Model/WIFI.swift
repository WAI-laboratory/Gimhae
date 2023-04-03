import Foundation

struct WIFIResponse: Codable {
    var status: String
    var message: String
    var data: [WIFI]
}

struct WIFI: Codable {
    var mgtNo: String
    var name: String
    var xCoordinate: String
    var yCoordinate: String
    var addr: String
}
