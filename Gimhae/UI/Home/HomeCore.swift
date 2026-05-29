//
//  HomeCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class HomeCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case loaded
    }
    
    struct State {
        var isLoading: Bool = false
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case .loaded:
            newState.isLoading = false
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ HomeCore: \(error)")
    }
}
