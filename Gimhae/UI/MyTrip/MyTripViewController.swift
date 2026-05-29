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
import Kingfisher

final class MyTripViewController: BaseViewController {
    
    private let core = MyTripCore()
    private let favoritesManager = FavoritesManager.shared
    private let cacheService = CacheService.shared
    
    // MARK: - UI
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private lazy var contentStack = VStackView().then {
        $0.spacing = 28
    }
    
    // Visit Stats
    private lazy var statsCard = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
    }
    private lazy var visitCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .systemBlue
    }
    private lazy var visitSubtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    private lazy var categoryCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .systemPurple
    }
    private lazy var categorySubtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    // Saved Places
    private lazy var savedSection = HomeSectionView(title: "myTrip.savedPlaces".localized)
    private lazy var savedTableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        tv.isScrollEnabled = false
        tv.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        tv.rowHeight = 60
        return tv
    }()
    
    // Checklist
    private lazy var checklistSection = HomeSectionView(title: "myTrip.checklist".localized)
    private lazy var checklistStack = VStackView().then { $0.spacing = 8 }
    private lazy var addChecklistButton = UIButton(type: .system).then {
        $0.setTitle("+ 항목 추가", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.addTarget(self, action: #selector(addChecklistItem), for: .touchUpInside)
    }
    
    // Cache info
    private lazy var cacheSection = HomeSectionView(title: "myTrip.offlineCache".localized)
    private lazy var cacheLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
    }
    private lazy var clearCacheButton = UIButton(type: .system).then {
        $0.setTitle("myTrip.clearAll".localized, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.tintColor = .systemRed
        $0.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
    }
    
    // Empty state
    private lazy var emptyLabel = UILabel().then {
        $0.text = "저장한 장소가 없습니다\n탐색에서 마음에 드는 장소를 저장해보세요"
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAll()
    }
    
    // MARK: - Setup
    
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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0))
            make.width.equalToSuperview()
        }
        
        // Stats card
        setupStatsCard()
        
        // Saved places
        contentStack.addArrangedSubview(savedSection)
        let tableWrapper = UIView()
        tableWrapper.addSubview(savedTableView)
        savedTableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0) // Dynamic
        }
        contentStack.addArrangedSubview(tableWrapper)
        
        // Checklist
        contentStack.addArrangedSubview(checklistSection)
        let checklistWrapper = UIView()
        checklistWrapper.addSubview(checklistStack)
        checklistWrapper.addSubview(addChecklistButton)
        checklistStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        addChecklistButton.snp.makeConstraints { make in
            make.top.equalTo(checklistStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
        }
        contentStack.addArrangedSubview(checklistWrapper)
        
        // Cache
        contentStack.addArrangedSubview(cacheSection)
        let cacheWrapper = HStackView([cacheLabel, clearCacheButton])
        cacheWrapper.spacing = 12
        let cacheContainer = UIView()
        cacheContainer.addSubview(cacheWrapper)
        cacheWrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        contentStack.addArrangedSubview(cacheContainer)
        
        // Empty label (over everything)
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    private func setupStatsCard() {
        let wrapper = UIView()
        wrapper.addSubview(statsCard)
        statsCard.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalTo(80)
        }
        
        let leftStack = VStackView([visitCountLabel, visitSubtitleLabel])
        leftStack.spacing = 4
        leftStack.alignment = .center
        
        let rightStack = VStackView([categoryCountLabel, categorySubtitleLabel])
        rightStack.spacing = 4
        rightStack.alignment = .center
        
        let hStack = HStackView([leftStack, rightStack])
        hStack.distribution = .fillEqually
        
        statsCard.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        contentStack.addArrangedSubview(wrapper)
    }
    
    // MARK: - Bind
    
    private func bindState() {
        favoritesManager.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAll()
            }
            .store(in: &subscription)
        
        core.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateChecklist(state.checklistItems)
            }
            .store(in: &subscription)
    }
    
    // MARK: - Update
    
    private func updateAll() {
        let favorites = favoritesManager.favorites
        let hasFavorites = !favorites.isEmpty
        
        emptyLabel.isHidden = hasFavorites || !core.state.checklistItems.isEmpty
        scrollView.isHidden = !hasFavorites && core.state.checklistItems.isEmpty
        
        // Stats
        visitCountLabel.text = "\(favorites.count)"
        visitSubtitleLabel.text = "myTrip.placesVisited".localized(with: favorites.count)
        
        let categories = Set(favorites.map(\.category)).count
        categoryCountLabel.text = "\(categories)"
        categorySubtitleLabel.text = "myTrip.categoriesExplored".localized(with: categories)
        
        // Table height
        savedTableView.snp.updateConstraints { make in
            make.height.equalTo(min(favorites.count, 5) * 60)
        }
        savedTableView.reloadData()
        
        // Cache
        cacheLabel.text = "캐시 사용량: \(cacheService.formattedCacheSize())"
    }
    
    private func updateChecklist(_ items: [MyTripCore.ChecklistItem]) {
        checklistStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for item in items {
            let row = makeChecklistRow(item)
            checklistStack.addArrangedSubview(row)
        }
    }
    
    private func makeChecklistRow(_ item: MyTripCore.ChecklistItem) -> UIView {
        let row = UIView()
        row.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        
        let checkbox = UIButton(type: .system)
        let imageName = item.isCompleted ? "checkmark.circle.fill" : "circle"
        checkbox.setImage(UIImage(systemName: imageName), for: .normal)
        checkbox.tintColor = item.isCompleted ? .systemGreen : .tertiaryLabel
        checkbox.tag = item.id.hashValue
        checkbox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.text = item.title
        label.font = .systemFont(ofSize: 15)
        label.textColor = item.isCompleted ? .tertiaryLabel : .label
        if item.isCompleted {
            let attr = NSAttributedString(string: item.title, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            label.attributedText = attr
        }
        
        row.addSubview(checkbox)
        row.addSubview(label)
        
        checkbox.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(checkbox.snp.trailing).offset(8)
            make.trailing.centerY.equalToSuperview()
        }
        
        // Store item ID for lookup
        row.accessibilityIdentifier = item.id
        
        return row
    }
    
    // MARK: - Actions
    
    @objc private func checkboxTapped(_ sender: UIButton) {
        // Find the item by matching hash
        if let item = core.state.checklistItems.first(where: { $0.id.hashValue == sender.tag }) {
            core.action(.toggleChecklistItem(item.id))
        }
    }
    
    @objc private func addChecklistItem() {
        let alert = UIAlertController(title: "항목 추가", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "할 일을 입력하세요" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self?.core.action(.addChecklistItem(text))
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func clearCache() {
        let alert = UIAlertController(title: "캐시 삭제", message: "오프라인에서 저장된 데이터가 모두 삭제됩니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.cacheService.clearAll()
            self?.cacheLabel.text = "캐시 사용량: \(self?.cacheService.formattedCacheSize() ?? "0 KB")"
        })
        present(alert, animated: true)
    }
}

// MARK: - Favorites TableView

extension MyTripViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        min(favoritesManager.favorites.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let item = favoritesManager.favorites[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = item.name
        config.secondaryText = item.address
        config.image = UIImage(systemName: item.category.iconName)
        config.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self = self else { return }
            let item = self.favoritesManager.favorites[indexPath.row]
            self.favoritesManager.remove(placeId: item.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
