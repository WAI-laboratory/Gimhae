import Foundation

struct DustResponse: Codable {
    var status: String
    var message: String
    var data: [Dust]
}

struct Dust: Codable {
    var dev: String
    var name: String
    var loc: String
    var coordx: String
    var coordy: String
    var ison: Bool
    var tenpm: Int
    var nextDaypm: Int
    var state: Int
    var timestamp: String
    var companyID: String
    var companyName: String
    
    enum CodingKeys: String, CodingKey {
        case dev = "dev_id"
        case name
        case loc
        case coordx
        case coordy
        case ison
        case tenpm = "pm10_after"
        case nextDaypm = "pm25_after"
        case state
        case timestamp
        case companyID = "company_id"
        case companyName = "company_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dev = try container.decode(String.self, forKey: .dev)
        self.name = try container.decode(String.self, forKey: .name)
        self.loc = try container.decode(String.self, forKey: .loc)
        self.coordx = try container.decode(String.self, forKey: .coordx)
        self.coordy = try container.decode(String.self, forKey: .coordy)
        self.ison = try container.decode(Bool.self, forKey: .ison)
        self.tenpm = try container.decode(Int.self, forKey: .tenpm)
        self.nextDaypm = try container.decode(Int.self, forKey: .nextDaypm)
        self.state = try container.decode(Int.self, forKey: .state)
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.companyID = try container.decode(String.self, forKey: .companyID)
        self.companyName = try container.decode(String.self, forKey: .companyName)
    }
    
    
    var latitude: Double? {
        return Double(self.coordy)
    }
    
    var longitude: Double? {
        return Double(self.coordx)
    }
}
