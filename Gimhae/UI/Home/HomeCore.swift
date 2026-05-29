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
        case setFestivals([Festival])
        case setRecommended([TourismSpot])
        case setDustSummary(DustSummary)
        case setLoading(Bool)
        case setError(String?)
    }
    
    struct DustSummary: Equatable {
        var averagePM10: Int = 0
        var averagePM25: Int = 0
        var overallState: DustState = .normal
        var sensorCount: Int = 0
    }
    
    struct State: Equatable {
        var activeFestivals: [Festival] = []
        var recommendedSpots: [TourismSpot] = []
        var dustSummary: DustSummary = .init()
        var isLoading: Bool = true
        var errorMessage: String? = nil
    }
    
    @Published var state: State = .init()
    
    private let festivalService = FestivalService()
    private let tourismService = TourismService.shared
    private let dustService = DustService.shared
    
    init() {
        loadAllData()
    }
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case let .setFestivals(festivals):
            newState.activeFestivals = festivals
        case let .setRecommended(spots):
            newState.recommendedSpots = spots
        case let .setDustSummary(summary):
            newState.dustSummary = summary
        case let .setLoading(loading):
            newState.isLoading = loading
        case let .setError(message):
            newState.errorMessage = message
        }
        return newState
    }
    
    func handleError(error: Error) {
        print("❤️ HomeCore: \(error)")
        action(.setError(error.localizedDescription))
        action(.setLoading(false))
    }
    
    func loadAllData() {
        action(.setLoading(true))
        
        // Festivals
        let festivals = festivalService.getFestivals(page: 1)
            .map { response -> [Festival] in
                // Filter to active festivals (simplified: just take first 5)
                return Array(response.results.prefix(5))
            }
            .map(Action.setFestivals)
        dispatch(effect: festivals)
        
        // Recommended spots
        let spots = tourismService.getTourismSpots(page: 1, pageunit: 10)
            .map { Array($0.results.prefix(6)) }
            .map(Action.setRecommended)
        dispatch(effect: spots)
        
        // Dust summary
        let dust = dustService.getDust()
            .map { response -> DustSummary in
                let dusts = response.data.filter { $0.ison }
                guard !dusts.isEmpty else { return DustSummary() }
                let avgPM10 = dusts.map(\.tenpm).reduce(0, +) / dusts.count
                let avgPM25 = dusts.map(\.superPm).reduce(0, +) / dusts.count
                // Determine overall state from average PM10
                let tempDust = Dust(from: dusts[0], overridePM10: avgPM10)
                return DustSummary(
                    averagePM10: avgPM10,
                    averagePM25: avgPM25,
                    overallState: tempDust?.tempmState ?? .normal,
                    sensorCount: dusts.count
                )
            }
            .map(Action.setDustSummary)
        dispatch(effect: dust)
        
        // Mark loading done after a delay (all fetches are parallel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.action(.setLoading(false))
        }
    }
}

// Helper to create a Dust for state calculation
private extension Dust {
    init?(from other: Dust, overridePM10: Int) {
        self = other
        self.tenpm = overridePM10
    }
}
