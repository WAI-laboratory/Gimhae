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
    
    private let wrapperView = UIView()
    private let wrapperStack = UIStackView()
    private let dustButton = MapComponentButton(image: UIImage(systemName: "facemask"), title: "미세먼지")
    private let bicycleButton = MapComponentButton(image: UIImage(systemName: "bicycle"), title: "전기 자전거")

    
    private var markers: [NMFMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        bind(core)
    }
    
    
    private func initView () {
        view.add(mapView) {
            $0.moveCamera(.init(position: .init(.init(lat: 35.25551631902464, lng: 128.8716916600828), zoom: 15)))
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        infoWindow.dataSource = defaultDataSource
        
        view.add(wrapperView) {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(44)
                make.centerX.equalToSuperview()
//                make.height.equalTo(76)
            }
        }
        wrapperView.add(wrapperStack) {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(24)
            }
            $0.addArrangedSubview(self.bicycleButton)
            $0.addArranged(UIView()) {
                $0.backgroundColor = .tertiaryLabel
                $0.snp.makeConstraints { make in
                    make.width.equalTo(1)
                }
            }
            $0.addArrangedSubview(self.dustButton)
        }
        
        
    }
    
    private func bind(_ core: MainCore) {
        core.getDustAction()
        core.getBicyclesAction()
        core.action(.setMapState(.bicycles))
        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
            if let marker = overlay as? NMFMarker {
                if let dust = marker.userInfo["dust"] as? Dust {
                    self?.defaultDataSource.title = "미세먼지: \(dust.tempmState.word)(\(dust.tenpm)㎍/m³)초미세먼지: \(dust.superPmState.word)(\(dust.superPm))"
                    self?.infoWindow.open(with: marker)
                } else if let bicycle = marker.userInfo["bicycle"] as? Bicycle {
                    if let self {
                        let bicycleInouts = self.core.state.bicycleInouts
                        if let bicycleInout = bicycleInouts.first(where: { $0.mgtNo == bicycle.mgtNo }) {
                            self.defaultDataSource.title = "대여수: \(bicycleInout.inCnt) 반납수: \(bicycleInout.outCnt)"
                            self.infoWindow.open(with: marker)
                        }
                    }
                }
            }
            return true
        }

        
        core.$state.map(\.currentMapState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapState in
                guard let self else { return }
                self.markers.forEach({ $0.mapView = nil })
                self.markers = []
                
                switch mapState {
                case .dusts:
                    let dusts = self.core.state.dusts
                    for dust in dusts {
                        if let lat = dust.latitude, let long = dust.longitude {
                            let marker = NMFMarker(position: .init(lat: lat, lng: long))
                            marker.mapView = self.mapView
                            marker.captionText = "미세먼지: \(dust.tempmState.word)(\(dust.tenpm)㎍/m³)\n초미세먼지: \(dust.superPmState.word)(\(dust.superPm))"
                            marker.captionHaloColor = .secondaryLabel
                            marker.captionColor = .label
                            marker.iconTintColor = dust.tempmState.color
                            marker.userInfo = ["dust": dust]
                            marker.touchHandler = handler
                            self.markers.append(marker)
                        }
                    }
                    
                    
                case .bicycles:
                    let bicycles = self.core.state.bicycles
                    for bicycle in bicycles {
                        if let lat = bicycle.latitude, let long = bicycle.longitude {
                            let marker = NMFMarker(position: .init(lat: lat, lng: long),iconImage: .init(image: UIImage(systemName: "bicycle.circle.fill")!))
                            marker.mapView = self.mapView
                            marker.captionText = "\(bicycle.name)"
                            marker.userInfo = ["bicycle": bicycle]
                            marker.touchHandler = handler
                            self.markers.append(marker)
                        }
                    }
                    
                    
                case .none: break
                    
                }
            }
            .store(in: &subscription)
        
    }
    
    func setBicycle() {
        core.getBicyclesAction()
    }
}



class CustomInfoView: UIView {
    // Add any subviews and customize their appearance as desired
    // ...
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        backgroundColor = .yellow
        snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(200)
        }
    }
}



class MapComponentButton: UIControl {
    private let imageView = UIImageView()
    private let label = UILabel()
    
    init(
        image: UIImage?,
        title: String
    ) {
        super.init(frame: .zero)
        imageView.image = image?.withRenderingMode(.alwaysTemplate).withTintColor(.label)
        label.font = .preferredFont(forTextStyle: .caption1)
        label.text = title
        label.textColor = .label
        
        add(imageView) {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(4)
                make.centerX.equalToSuperview()
                make.width.equalTo(32)
            }
        }
        
        add(label) {
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.imageView.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(44)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

