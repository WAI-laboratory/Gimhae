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

final class HomeViewController: BaseViewController {
    
    private let core = HomeCore()
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 24
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "tab.home".localized
        
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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 40, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
        
        // Placeholder sections for Phase 3
        let sections = [
            "home.happeningNow".localized,
            "home.recommended".localized,
            "home.todayAir".localized,
            "home.atAGlance".localized
        ]
        
        for section in sections {
            let sectionView = makeSectionPlaceholder(title: section)
            contentStack.addArrangedSubview(sectionView)
        }
    }
    
    private func makeSectionPlaceholder(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let comingSoon = UILabel()
        comingSoon.text = "Phase 3에서 구현 예정"
        comingSoon.font = .systemFont(ofSize: 13, weight: .regular)
        comingSoon.textColor = .tertiaryLabel
        
        container.addSubview(label)
        container.addSubview(comingSoon)
        
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        comingSoon.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        container.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        
        return container
    }
    
    private func bindState() {
        // Will be implemented in Phase 3
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
