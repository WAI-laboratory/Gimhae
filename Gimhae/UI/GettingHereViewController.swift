//
//  GettingHereViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import SnapKit
import AddThen

/// "김해 가는 법" — How to get to Gimhae
final class GettingHereViewController: BaseViewController {
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buildContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "김해 가는 법"
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
    }
    
    private func buildContent() {
        let intro = makeInfoCard(
            icon: "airplane",
            title: "비행기",
            details: """
            김해국제공항 (PUS)
            • 국내선: 서울(김포), 제주 등
            • 국제선: 일본, 중국, 동남아 노선
            • 공항에서 시내: 경전철 이용 (약 20분)
            """
        )
        
        let train = makeInfoCard(
            icon: "tram.fill",
            title: "KTX / SRT",
            details: """
            김해 직통 열차는 없음
            • 부산역 → 부산-김해경전철 (약 40분)
            • 구포역 (KTX 정차) → 경전철 (약 25분)
            • 서울 → 부산 KTX 약 2시간 30분
            """
        )
        
        let bus = makeInfoCard(
            icon: "bus.fill",
            title: "시외/고속버스",
            details: """
            김해시외버스터미널
            • 서울 → 김해: 약 4시간 30분
            • 대구 → 김해: 약 1시간 30분
            • 부산 → 김해: 약 40분
            """
        )
        
        let transit = makeInfoCard(
            icon: "tram",
            title: "부산-김해경전철",
            details: """
            부산 ↔ 김해 연결
            • 사상역 (부산 2호선) ↔ 가야대역
            • 배차간격: 6~8분
            • 소요시간: 전구간 약 35분
            • 주요역: 김해공항, 봉황역, 수로왕릉역, 박물관역
            """
        )
        
        let car = makeInfoCard(
            icon: "car.fill",
            title: "자동차",
            details: """
            • 부산 → 김해: 남해고속도로 약 30분
            • 대구 → 김해: 경부/남해고속도로 약 1시간 30분
            • 서울 → 김해: 경부고속도로 약 4시간
            • 주차: 수로왕릉, 연지공원 무료 주차 가능
            """
        )
        
        [intro, train, bus, transit, car].forEach {
            contentStack.addArrangedSubview($0)
        }
    }
    
    private func makeInfoCard(icon: String, title: String, details: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let detailLabel = UILabel()
        detailLabel.text = details
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(detailLabel)
        
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(iconView.snp.trailing).offset(10)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        return card
    }
}
