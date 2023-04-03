//

import Foundation

struct BicycleResponse: Codable {
    var status: String
    var message: String
    var data: [Bicycle]

}
struct Bicycle: Codable {
    var mgtNo: String
    var name: String
    var xCoordinate: String
    var yCoordinate: String
    var addr: String
}
