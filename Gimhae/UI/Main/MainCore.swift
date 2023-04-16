import Combine
import CoreEngine

class MainCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case breakOut
        case getDust([Dust])
        case getBicycle([Bicycle])
        case getBicycleInouts([BicycleInOut])
        case getHeritage()
        case setMapState(MapState)
    }
    
    enum MapState: Equatable {
        case dusts
        case bicycles
        case heritage
        case none
    }
    
    struct State {
        var dusts: [Dust] = []
        var bicycles: [Bicycle] = []
        var bicycleInouts: [BicycleInOut] = []
        var currentMapState: MapState = .none
    }
    private let dustService = DustService.shared
    private let bicycleService = BicycleService.shared
    private let bicycleInoutService = BicycleInOutSerivce.shared
    private let heritageSerivce = HeritageService.shared
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case .breakOut:
            break
        case let .getDust(values):
            newState.dusts = values
        case let .getBicycle(value):
            newState.bicycles = value
        case let .setMapState(value):
            newState.currentMapState = value
        case let .getBicycleInouts(value):
            newState.bicycleInouts = value
        }
        return newState
    }
    
    func getDustAction() {
        let getDust = dustService.getDust()
            .map(\.data)
            .map(Action.getDust)
        dispatch(effect: getDust)
    }
    
    func getBicyclesAction() {
        let getBicycles = bicycleService.get()
            .map(\.data)
            .map(Action.getBicycle)
        dispatch(effect: getBicycles)
        
        let getBicycleInouts = bicycleInoutService.get()
            .map(\.data)
            .map(Action.getBicycleInouts)
        dispatch(effect: getBicycleInouts)
    }
    
    func handleError(error: Error) {
        print("❤️ \(error)")
    }
}
