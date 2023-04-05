import UIKit
import Combine
import NMapsMap
import AddThen
import CoreEngine

class MainViewController: BaseViewController {
    private var mapView = NMFMapView.init()
    private var core = MainCore()
    
    let defaultDataSource: NMFInfoWindowDefaultTextSource = {
        let defaultDataSource = NMFInfoWindowDefaultTextSource.data()
        defaultDataSource.title = "정보 창 내용"
        return defaultDataSource
    }()
    
    let infoWindow: NMFInfoWindow = {
        let infoWindow = NMFInfoWindow()
        return infoWindow
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        bind(core)
    }
    
    
    private func initView () {
        view.add(mapView) {
            $0.moveCamera(.init(position: .init(.init(lat: 35.25551631902464, lng: 128.8716916600828), zoom: 15)))
            $0.touchDelegate = self
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        infoWindow.dataSource = defaultDataSource
    }
    
    private func bind(_ core: MainCore) {
        core.getDustAction()
        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
            if let marker = overlay as? NMFMarker {
                let dust = marker.userInfo["dust"] as! Dust
                print("❤️ \(dust)")
                self?.defaultDataSource.title = "\(dust.loc)\n미세먼지: \(dust.tenpm)\n초미세먼지: \(dust.superPm)"
                self?.infoWindow.open(with: marker)
            }
            return true
        }

        core.$state.map(\.dusts)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dusts in
                guard let self = self else { return }
                for dust in dusts {
                    if let lat = dust.latitude, let long = dust.longitude {
                        let marker = NMFMarker(position: .init(lat: lat, lng: long))
                        marker.mapView = self.mapView
                        marker.userInfo = ["dust": dust]
                        marker.touchHandler = handler
                    }
                }
            }
            .store(in: &subscription)
        
        
        
    }
}


extension MainViewController: NMFMapViewTouchDelegate {
    
}
