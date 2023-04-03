import UIKit
import Combine
import NMapsMap
import AddThen
import CoreEngine

class MainViewController: BaseViewController {
    private var mapView = NMFMapView.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    
    private func initView () {
        view.add(mapView) {
            $0.moveCamera(.init(position: .init(.init(lat: 35.25551631902464, lng: 128.8716916600828), zoom: 15)))
            $0.touchDelegate = self
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func bind(_ core: MainCore) {
        core.getDustAction()
        
        core.$state.map(\.dusts)
            .sink { [weak self] dusts in
                guard let self = self else { return }
                
                print("❤️ \(dusts.first?.longitude)")
            }
            .store(in: &subscription)
        
        
        
    }
}


extension MainViewController: NMFMapViewTouchDelegate {
    
}
