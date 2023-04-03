import Combine
import CoreEngine

class CardIntroduceCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    enum Action {
        case getFestival([Festival])
    }
    
    struct State {
        var models: [CardIntroduceModel] = []
    }
    @Published var state: State = .init()
    private let festivalService = FestivalService()
    init() {
        getFestivlas()
        
    }
    
    func reduce(state: State, action: Action) -> State {
        var newState = state
        switch action {
        case let .getFestival(festivals):
            let items = festivals.map({ return CardIntroduceItem.festival($0)})
            newState.models = [.init(section: "", items: items)]
            
        }
        return newState
    }
    
    func getFestivlas() {
        let getFestivals$ = festivalService.getFestivals(page: 1).map(\.results).map(Action.getFestival)
        dispatch(effect: getFestivals$)
    }
    
}


enum CardIntroduceItem: Equatable {

    
    case festival(Festival)
    
    static func == (lhs: CardIntroduceItem, rhs: CardIntroduceItem) -> Bool {
        switch (lhs, rhs){
        case (let .festival(lhsF), let .festival(rhsF)):
            return lhsF.idx == rhsF.idx
        }
    }
    
}

typealias CardIntroduceSection = String
struct CardIntroduceModel: Equatable {
    var section: CardIntroduceSection
    var items: [CardIntroduceItem]
}

