//
//  ExploreViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class ExploreViewController: BaseViewController {
    
    private let core = ExploreCore()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        return cv
    }()
    
    private let categories = PlaceCategory.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "tab.explore".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        cell.configure(with: categories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20 - 20 - 12) / 2
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        let listVC = PlaceListViewController(category: category)
        navigationController?.pushViewController(listVC, animated: true)
    }
}

// MARK: - Category Cell

final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.size.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom).offset(8)
        }
    }
    
    func configure(with category: PlaceCategory) {
        iconView.image = UIImage(systemName: category.iconName)
        titleLabel.text = category.title
    }
}
