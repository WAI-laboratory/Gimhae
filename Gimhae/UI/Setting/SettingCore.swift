import Foundation
import UIKit
import CoreEngine
import Combine

class SettingCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        
    }
    
    struct State {
        var models: [SettingModel] = [
            .init(section: .common, item: .sendMail),
            .init(section: .common, item: .version),
        ]
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        
        
        return state
    }
}







enum SettingItem: Equatable {
    case label(String)
    case version
    case sendMail
}


enum SettingSection: CaseIterable {
    case common

    
    
    var title: String {
        return "\(self)"
    }
}

struct SettingModel {
    var section: SettingSection
    var item: SettingItem
}
