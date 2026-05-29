//
//  PlaceDetailViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import FSPagerView
import MapKit

final class PlaceDetailViewController: BaseViewController {
    
    private let place: any Place
    private let favoritesManager = FavoritesManager.shared
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 16
    }
    
    private lazy var pagerView: FSPagerView = {
        let pager = FSPagerView()
        pager.delegate = self
        pager.dataSource = self
        pager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        pager.isInfinite = true
        pager.automaticSlidingInterval = 4.0
        return pager
    }()
    
    private lazy var pageControl: FSPageControl = {
        let control = FSPageControl()
        control.setFillColor(.white, for: .selected)
        control.setFillColor(.white.withAlphaComponent(0.4), for: .normal)
        return control
    }()
    
    private lazy var nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.numberOfLines = 0
    }
    
    private lazy var categoryBadge = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private lazy var addressLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
    
    private lazy var contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
    }
    
    private lazy var infoStack = VStackView().then {
        $0.spacing = 8
    }
    
    private lazy var buttonStack = HStackView().then {
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private lazy var saveButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.addTarget(self, action: #selector(toggleSave), for: .touchUpInside)
    }
    
    private lazy var directionsButton = UIButton(type: .system).then {
        $0.setTitle("detail.getDirections".localized, for: .normal)
        $0.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.tintColor = .white
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(openDirections), for: .touchUpInside)
    }
    
    // MARK: - Init
    
    init(place: any Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
        updateSaveButton()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = place.placeName
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Image pager
        scrollView.addSubview(pagerView)
        pagerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(250)
        }
        
        pagerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
        
        // Content below image
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(pagerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
            make.width.equalToSuperview().offset(-40)
        }
        
        // Category badge + name
        let headerStack = HStackView([categoryBadge, UIView()])
        headerStack.spacing = 8
        
        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(addressLabel)
        
        // Buttons
        buttonStack.addArrangedSubview(saveButton)
        buttonStack.addArrangedSubview(directionsButton)
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        contentStack.addArrangedSubview(buttonStack)
        
        // Separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        contentStack.addArrangedSubview(separator)
        
        // Info section
        contentStack.addArrangedSubview(infoStack)
        
        // Content/description
        contentStack.addArrangedSubview(contentLabel)
    }
    
    // MARK: - Configure
    
    private func configure() {
        nameLabel.text = place.placeName
        addressLabel.text = place.placeAddress
        
        categoryBadge.text = "  \(place.placeCategory.title)  "
        categoryBadge.backgroundColor = colorForCategory(place.placeCategory)
        
        pageControl.numberOfPages = place.placeImages.count
        
        // Try to extract extra info from specific model types
        if let tourism = place as? TourismSpot {
            addInfoRow(icon: "clock", title: "detail.hours".localized, value: tourism.userhour)
            addInfoRow(icon: "wonsign.circle", title: "detail.fee".localized, value: tourism.fee)
            addInfoRow(icon: "car", title: "detail.parking".localized, value: tourism.parking)
            addInfoRow(icon: "phone", title: "detail.phone".localized, value: tourism.phone)
            contentLabel.text = tourism.content
        } else if let heritage = place as? GimhaeHeritage {
            addInfoRow(icon: "clock", title: "detail.hours".localized, value: heritage.usehour)
            addInfoRow(icon: "wonsign.circle", title: "detail.fee".localized, value: heritage.fee)
            addInfoRow(icon: "car", title: "detail.parking".localized, value: heritage.parking)
            addInfoRow(icon: "number", title: "문화재 번호", value: heritage.assetnumber)
            contentLabel.text = heritage.content
        } else if let festival = place as? Festival {
            addInfoRow(icon: "calendar", title: "기간", value: "\(festival.sdate) ~ \(festival.edate)")
            addInfoRow(icon: "person", title: "주관", value: festival.opener)
            addInfoRow(icon: "wonsign.circle", title: "detail.fee".localized, value: festival.fee)
            addInfoRow(icon: "car", title: "detail.parking".localized, value: festival.parking)
            contentLabel.text = festival.copy
        } else {
            contentLabel.text = place.placeSummary
        }
    }
    
    private func addInfoRow(icon: String, title: String, value: String) {
        guard !value.isEmpty else { return }
        
        let row = HStackView()
        row.spacing = 8
        row.alignment = .top
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .secondaryLabel
        iconView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 13, weight: .medium)
        titleLbl.textColor = .secondaryLabel
        titleLbl.setContentHuggingPriority(.required, for: .horizontal)
        titleLbl.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = .systemFont(ofSize: 13, weight: .regular)
        valueLbl.textColor = .label
        valueLbl.numberOfLines = 0
        
        row.addArrangedSubview(iconView)
        row.addArrangedSubview(titleLbl)
        row.addArrangedSubview(valueLbl)
        
        infoStack.addArrangedSubview(row)
    }
    
    // MARK: - Actions
    
    @objc private func toggleSave() {
        favoritesManager.toggle(place: place)
        updateSaveButton()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func openDirections() {
        guard let coord = place.placeCoordinate else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        mapItem.name = place.placeName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    private func updateSaveButton() {
        let isSaved = favoritesManager.isFavorite(placeId: place.placeId)
        if isSaved {
            saveButton.setTitle("detail.saved".localized, for: .normal)
            saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            saveButton.tintColor = .systemRed
            saveButton.setTitleColor(.systemRed, for: .normal)
            saveButton.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            saveButton.setTitle("detail.save".localized, for: .normal)
            saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
            saveButton.tintColor = .label
            saveButton.setTitleColor(.label, for: .normal)
            saveButton.layer.borderColor = UIColor.separator.cgColor
        }
    }
    
    private func colorForCategory(_ category: PlaceCategory) -> UIColor {
        switch category {
        case .attraction: return .systemBlue
        case .restaurant: return .systemOrange
        case .heritage: return .systemBrown
        case .festival: return .systemPurple
        case .accommodation: return .systemTeal
        case .parking: return .systemGray
        case .wifi: return .systemGreen
        case .bicycle: return .systemYellow
        }
    }
}

// MARK: - FSPagerView

extension PlaceDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        place.placeImages.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "ImageCell", at: index)
        if let url = URL(string: place.placeImages[index]) {
            cell.imageView?.kf.setImage(with: url)
        }
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}
