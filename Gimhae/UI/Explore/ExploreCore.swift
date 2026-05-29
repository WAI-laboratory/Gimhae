//
//  ExploreCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class ExploreCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case setCategory(PlaceCategory)
        case loaded
    }
    
    struct State {
        var selectedCategory: PlaceCategory? = nil
        var isLoading: Bool = false
    }
    
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case let .setCategory(category):
            newState.selectedCategory = category
        case .loaded:
            newState.isLoading = false
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ ExploreCore: \(error)")
    }
}
