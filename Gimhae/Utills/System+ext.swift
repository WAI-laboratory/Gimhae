import Foundation
import UIKit

enum UserInterfaceStyle: Equatable {
    case dark
    case light
}

var userInterfaceStyle: UserInterfaceStyle {
    switch UIScreen.main.traitCollection.userInterfaceStyle {
    case .dark:
        return .dark
    case .light:
        return .light
    default:
        return .light
    }
}

struct SimpleError: Error {
    var message: String
}

struct DecodeFailedError: Error {
    var json: String
    
    init(data: Data) {
        self.json = String(data: data, encoding: .utf8) ?? ""
    }
}
