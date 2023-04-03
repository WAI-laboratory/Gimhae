import Foundation
import UIKit

struct DustResponse: Codable {
    var status: String
    var message: String
    var data: [Dust]
}

struct Dust: Codable, Equatable {
    var dev: String
    var name: String
    var loc: String
    var coordx: String
    var coordy: String
    var ison: Bool
    var tenpm: Int
    var superPm: Int
    var state: Int
    var timestamp: String
    var companyID: String
    var companyName: String
    
    var tempmState: DustState {
        switch tenpm {
        case (Int.min...15): return .best
        case (15...30): return .good
        case (31...40): return .fair
        case (41...50): return .normal
        case (51...75): return .poor
        case (76...100): return .worse
        case (101...150): return .critical
        default: return .hazard
        }
    }
    
    var superPmState: DustState {
        switch superPm {
        case (Int.min...8): return .best
        case (9...15): return .good
        case (16...20): return .fair
        case (21...25): return .normal
        case (26...37): return .poor
        case (38...50): return .worse
        case (51...75): return .critical
        default: return .hazard
        }
    }
    
    
    
    enum CodingKeys: String, CodingKey {
        case dev = "dev_id"
        case name
        case loc
        case coordx
        case coordy
        case ison
        case tenpm = "pm10_after"
        case superPm = "pm25_after"
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
        self.superPm = try container.decode(Int.self, forKey: .superPm)
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


enum DustState: String {
    case best
    case good
    case fair // 양호
    case normal
    case poor
    case worse // 상당히 나쁨
    case critical // 매우 나쁨
    case hazard // 최악
    
    var word: String {
        switch self {
        case .best: return "최고"
        case .good: return "좋음"
        case .fair: return "양호"
        case .normal: return "보통"
        case .poor: return "나쁨"
        case .worse: return "상당히 나쁨"
        case .critical: return "매우 나쁨"
        case .hazard: return "최악"
        }
    }
    
    var color: UIColor {
        switch self {
        case .best: return UIColor.init(47, 115, 186)
        case .good: return UIColor.init(40, 154, 213)
        case .fair: return UIColor.init(21, 173, 194)
        case .normal: return UIColor.init(52, 144, 67)
        case .poor: return UIColor.init(247, 141, 31)
        case .worse: return UIColor.init(230, 77, 34)
        case .critical: return UIColor.init(218, 43, 46)
        case .hazard: return UIColor.init(33, 33, 32)
        }
    }
    
}



extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        self.init(red: CGFloat(red) / CGFloat(255), green: CGFloat(green) / CGFloat(255), blue: CGFloat(blue) / CGFloat(255), alpha: 1)
    }
}
