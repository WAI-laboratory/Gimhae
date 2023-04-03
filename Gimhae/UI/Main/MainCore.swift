import Combine
import CoreEngine
import CodableFirebase
import FirebaseFirestore

class MainCore: AnyCore {
    var subscription: Set<AnyCancellable> = .init()
    
    enum Action {
        case breakOut
        case getDust([Dust])
        case getBicycle([Bicycle])
        case getBicycleInouts([BicycleInOut])
        case getHeritage([GimhaeHeritage])
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
        var heritages: [GimhaeHeritage] = []
        var currentMapState: MapState = .none
    }
    private let dustService = DustService.shared
    private let bicycleService = BicycleService.shared
    private let bicycleInoutService = BicycleInOutSerivce.shared
    private let heritageSerivce = HeritageService.shared
    @Published var state: State = .init()
    
    init() {
        getHeritages()
    }
    
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
        case let .getHeritage(value):
            newState.heritages = value
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
    
    func getHeritages() {
        Firestore.firestore().collection("model").getDocuments { [weak self] snapShort, error in
            if let snapShort {
                var gimhaeHeritages: [GimhaeHeritage] = []
                for document in snapShort.documents {
                    let model = try! FirestoreDecoder().decode(GimhaeHeritage.self, from: document.data())
                    gimhaeHeritages.append(model)
                }

                self?.action(.getHeritage(gimhaeHeritages))
            }
        }
        
    }
}
