//
//  HomeViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen
import Kingfisher

final class HomeViewController: BaseViewController {
    
    private let core = HomeCore()
    
    // MARK: - UI
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.refreshControl = refreshControl
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 28
    }
    
    // Sections
    private lazy var happeningSection = HomeSectionView(title: "home.happeningNow".localized)
    private lazy var recommendedSection = HomeSectionView(title: "home.recommended".localized)
    private lazy var airSection = HomeSectionView(title: "home.todayAir".localized)
    
    // Happening now - horizontal scroll
    private lazy var festivalScroll: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return sv
    }()
    private lazy var festivalStack = HStackView().then { $0.spacing = 12 }
    
    // Recommended - horizontal scroll
    private lazy var spotScroll: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return sv
    }()
    private lazy var spotStack = HStackView().then { $0.spacing = 12 }
    
    // Air quality
    private lazy var airCard = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
    }
    private lazy var airStateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 32, weight: .bold)
    }
    private lazy var airDetailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "김해"
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.rightBarButtonItem = settingsButton
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // --- Happening Now ---
        contentStack.addArrangedSubview(happeningSection)
        festivalScroll.addSubview(festivalStack)
        festivalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        festivalScroll.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        contentStack.addArrangedSubview(festivalScroll)
        
        // --- Recommended ---
        contentStack.addArrangedSubview(recommendedSection)
        spotScroll.addSubview(spotStack)
        spotStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        spotScroll.snp.makeConstraints { make in
            make.height.equalTo(180)
        }
        contentStack.addArrangedSubview(spotScroll)
        
        // --- Air Quality ---
        contentStack.addArrangedSubview(airSection)
        setupAirCard()
    }
    
    private func setupAirCard() {
        let wrapper = UIView()
        wrapper.addSubview(airCard)
        airCard.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        airCard.addSubview(airStateLabel)
        airCard.addSubview(airDetailLabel)
        
        airStateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        airDetailLabel.snp.makeConstraints { make in
            make.leading.equalTo(airStateLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        contentStack.addArrangedSubview(wrapper)
    }
    
    // MARK: - Bind
    
    private func bindState() {
        core.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.refreshControl.endRefreshing()
                self?.updateFestivals(state.activeFestivals)
                self?.updateRecommended(state.recommendedSpots)
                self?.updateAir(state.dustSummary)
            }
            .store(in: &subscription)
    }
    
    // MARK: - Update UI
    
    private func updateFestivals(_ festivals: [Festival]) {
        festivalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for festival in festivals {
            let card = makeFestivalCard(festival)
            festivalStack.addArrangedSubview(card)
        }
        
        if festivals.isEmpty {
            let empty = UILabel()
            empty.text = "현재 진행 중인 행사가 없습니다"
            empty.font = .systemFont(ofSize: 14)
            empty.textColor = .tertiaryLabel
            festivalStack.addArrangedSubview(empty)
        }
    }
    
    private func updateRecommended(_ spots: [TourismSpot]) {
        spotStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for spot in spots {
            let card = makeSpotCard(spot)
            spotStack.addArrangedSubview(card)
        }
    }
    
    private func updateAir(_ summary: HomeCore.DustSummary) {
        airStateLabel.text = summary.overallState.word
        airStateLabel.textColor = summary.overallState.color
        airDetailLabel.text = "PM10: \(summary.averagePM10)㎍/㎥\nPM2.5: \(summary.averagePM25)㎍/㎥\n측정소 \(summary.sensorCount)개 평균"
    }
    
    // MARK: - Card Builders
    
    private func makeFestivalCard(_ festival: Festival) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.snp.makeConstraints { make in
            make.width.equalTo(240)
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if let url = festival.images.first.flatMap({ URL(string: $0) }) {
            imageView.kf.setImage(with: url)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = festival.placeName
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        let dateLabel = UILabel()
        dateLabel.text = "\(festival.sdate) ~ \(festival.edate)"
        dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        
        card.addSubview(imageView)
        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(festivalCardTapped(_:)))
        card.addGestureRecognizer(tap)
        card.tag = festival.idx
        card.isUserInteractionEnabled = true
        
        return card
    }
    
    private func makeSpotCard(_ spot: TourismSpot) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.snp.makeConstraints { make in
            make.width.equalTo(150)
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if let url = spot.images.first.flatMap({ URL(string: $0) }) {
            imageView.kf.setImage(with: url)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = spot.placeName
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        let areaLabel = UILabel()
        areaLabel.text = spot.area
        areaLabel.font = .systemFont(ofSize: 11)
        areaLabel.textColor = .secondaryLabel
        
        card.addSubview(imageView)
        card.addSubview(titleLabel)
        card.addSubview(areaLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        areaLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(spotCardTapped(_:)))
        card.addGestureRecognizer(tap)
        card.tag = spot.idx
        card.isUserInteractionEnabled = true
        
        return card
    }
    
    // MARK: - Actions
    
    @objc private func refresh() {
        core.loadAllData()
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func festivalCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let idx = gesture.view?.tag else { return }
        if let festival = core.state.activeFestivals.first(where: { $0.idx == idx }) {
            let detail = PlaceDetailViewController(place: festival)
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    @objc private func spotCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let idx = gesture.view?.tag else { return }
        if let spot = core.state.recommendedSpots.first(where: { $0.idx == idx }) {
            let detail = PlaceDetailViewController(place: spot)
            navigationController?.pushViewController(detail, animated: true)
        }
    }
}

// MARK: - Section Header View

final class HomeSectionView: UIView {
    private let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
