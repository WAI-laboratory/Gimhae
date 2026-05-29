//
//  MyTripViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class MyTripViewController: BaseViewController {
    
    private let core = MyTripCore()
    private let favoritesManager = FavoritesManager.shared
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 24
    }
    
    private lazy var emptyLabel = UILabel().then {
        $0.text = "저장한 장소가 없습니다\n탐색에서 마음에 드는 장소를 저장해보세요"
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "tab.myTrip".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 40, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
        
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    private func updateUI() {
        let hasFavorites = favoritesManager.count > 0
        emptyLabel.isHidden = hasFavorites
        scrollView.isHidden = !hasFavorites
    }
    
    private func bindState() {
        favoritesManager.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &subscription)
    }
}
