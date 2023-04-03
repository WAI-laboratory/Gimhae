import UIKit
import Combine
import NMapsMap
import AddThen
import CoreEngine
import CombineCocoa
import BetterSegmentedControl
import FirebaseFirestore
import CodableFirebase
import FirebaseCore

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
    private var segmentControl = BetterSegmentedControl.init(
        frame: .zero,
        segments: [
            IconSegment.init(icon: UIImage(systemName: "facemask")!, iconSize: .init(width: 24, height: 24), normalIconTintColor: .label, selectedIconTintColor: .brown),
            IconSegment.init(icon: UIImage(systemName: "bicycle")!, iconSize: .init(width: 24, height: 24), normalIconTintColor: .label, selectedIconTintColor: .brown),
            LabelSegment.init(text: "문화유산")
        ],
        options: [
            .cornerRadius(24.0),
            .backgroundColor(UIColor(red: 0.16, green: 0.64, blue: 0.94, alpha: 1.00)),
            .indicatorViewBackgroundColor(.white)]
    )
    
    
    private var markers: [NMFMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        bind(core)

    }
    
    
    private func initView () {
        navigationController?.navigationBar.isHidden = true
        view.add(mapView) {
            $0.isNightModeEnabled = true
            $0.moveCamera(.init(position: .init(.init(lat: 35.25551631902464, lng: 128.8716916600828), zoom: 15)))
            $0.snp.makeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
            }
        }
        infoWindow.dataSource = defaultDataSource
        view.backgroundColor = .systemBackground
        view.add(segmentControl) {
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(24)
                make.height.equalTo(52)
            }
        }
        

    }
    
    private func bind(_ core: MainCore) {
        core.getDustAction()
        core.getBicyclesAction()
        core.action(.setMapState(.dusts))
        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
            guard let self else { return false }
            if let marker = overlay as? NMFMarker {
                if let dust = marker.userInfo["dust"] as? Dust {
                    self.defaultDataSource.title = "미세먼지: \(dust.tempmState.word)(\(dust.tenpm)㎍/m³)초미세먼지: \(dust.superPmState.word)(\(dust.superPm))"
                    self.infoWindow.open(with: marker)
                } else if let bicycle = marker.userInfo["bicycle"] as? Bicycle {
                    
                    let bicycleInouts = self.core.state.bicycleInouts
                    if let bicycleInout = bicycleInouts.first(where: { $0.mgtNo == bicycle.mgtNo }) {
                        self.defaultDataSource.title = "대여수: \(bicycleInout.inCnt) 반납수: \(bicycleInout.outCnt)"
                        self.infoWindow.open(with: marker)
                    }
                    
                } else if let heritage = marker.userInfo["heritage"] as? GimhaeHeritage {
                    self.defaultDataSource.title = "\(heritage.content)"
                    self.present(HeritageViewController(heritage: heritage), animated: true)
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
                    
                case .heritage:
                    let heritages = self.core.state.heritages
                    for heritage in heritages {
                        if let lat = Double(heritage.xposition), let long = Double(heritage.yposition) {
                            let marker = NMFMarker(position: .init(lat: lat, lng: long), iconImage: .init(image: UIImage(systemName: "gift.circle.fill")!))
                            marker.mapView = self.mapView
                            marker.captionText = "\(heritage.name)"
                            marker.userInfo = ["heritage": heritage]
                            marker.touchHandler = handler
                            self.markers.append(marker)
                        }
                    }
                    
                case .none: break
                    
                }
            }
            .store(in: &subscription)
        
        segmentControl.addTarget(self, action: #selector(self.segmentedControl1ValueChanged(_:)), for: .valueChanged)
        
    }
    
    func setBicycle() {
        core.getBicyclesAction()
    }
    
    @objc private func segmentedControl1ValueChanged(_ sender: BetterSegmentedControl) {
        switch sender.index {
        case 0: self.core.action(.setMapState(.dusts))
        case 1: self.core.action(.setMapState(.bicycles))
        case 2: self.core.action(.setMapState(.heritage))
        default: break
        }
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

