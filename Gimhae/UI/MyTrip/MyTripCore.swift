//
//  MyTripCore.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import Foundation
import Combine
import CoreEngine

final class MyTripCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case setChecklistItems([ChecklistItem])
        case toggleChecklistItem(String)
        case addChecklistItem(String)
        case removeChecklistItem(String)
    }
    
    struct ChecklistItem: Codable, Equatable, Identifiable {
        let id: String
        var title: String
        var isCompleted: Bool
        
        init(title: String) {
            self.id = UUID().uuidString
            self.title = title
            self.isCompleted = false
        }
    }
    
    struct State: Equatable {
        var checklistItems: [ChecklistItem] = []
    }
    
    @Published var state: State = .init()
    
    private let checklistKey = "gimhae_checklist"
    
    init() {
        loadChecklist()
    }
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case let .setChecklistItems(items):
            newState.checklistItems = items
        case let .toggleChecklistItem(id):
            if let index = newState.checklistItems.firstIndex(where: { $0.id == id }) {
                newState.checklistItems[index].isCompleted.toggle()
            }
        case let .addChecklistItem(title):
            let item = ChecklistItem(title: title)
            newState.checklistItems.append(item)
        case let .removeChecklistItem(id):
            newState.checklistItems.removeAll(where: { $0.id == id })
        }
        saveChecklist(newState.checklistItems)
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ MyTripCore: \(error)")
    }
    
    // MARK: - Persistence
    
    private func loadChecklist() {
        guard let data = UserDefaults.standard.data(forKey: checklistKey),
              let items = try? JSONDecoder().decode([ChecklistItem].self, from: data) else {
            // Pre-populate with suggestions
            let suggestions = [
                ChecklistItem(title: "수로왕릉 방문"),
                ChecklistItem(title: "봉하마을 가기"),
                ChecklistItem(title: "김해 뒷골목 맛집 탐방"),
                ChecklistItem(title: "국립김해박물관"),
                ChecklistItem(title: "연지공원 자전거 타기")
            ]
            action(.setChecklistItems(suggestions))
            return
        }
        action(.setChecklistItems(items))
    }
    
    private func saveChecklist(_ items: [ChecklistItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: checklistKey)
    }
}
