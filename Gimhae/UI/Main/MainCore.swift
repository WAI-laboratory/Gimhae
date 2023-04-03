import Combine
import CoreEngine

class MainCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case breakOut
        case getDust([Dust])
        
    }
    
    struct State {
        var dusts: [Dust] = []
        
    }
    private let dustService = DustService.shared
    @Published var state: State = .init()
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case .breakOut:
            break
        case let .getDust(values):
            newState.dusts = values
        }
        return newState
    }
    
    func getDustAction() {
        let getDust = dustService.getDust()
            .map(\.data)
            .map(Action.getDust)
        dispatch(effect: getDust)
    }
}
