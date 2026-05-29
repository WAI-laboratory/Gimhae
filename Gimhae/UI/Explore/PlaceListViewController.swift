//
//  PlaceListViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class PlaceListViewController: BaseViewController {
    
    private let category: PlaceCategory
    private var places: [any Place] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(PlaceListCell.self, forCellReuseIdentifier: PlaceListCell.identifier)
        tv.rowHeight = 96
        tv.separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        tv.refreshControl = refreshControl
        return tv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return rc
    }()
    
    private lazy var emptyLabel = UILabel().then {
        $0.text = "common.noResults".localized
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(category: PlaceCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = category.title
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Data Fetching
    
    @objc private func refreshData() {
        fetchData()
    }
    
    private func fetchData() {
        loadingIndicator.startAnimating()
        emptyLabel.isHidden = true
        
        let publisher: AnyPublisher<[any Place], Error>
        
        switch category {
        case .attraction:
            publisher = TourismService.shared.getTourismSpots(page: 1, pageunit: 100)
                .map { $0.results as [any Place] }
                .eraseToAnyPublisher()
            
        case .festival:
            let service = FestivalService()
            publisher = service.getFestivals(page: 1)
                .map { $0.results as [any Place] }
                .eraseToAnyPublisher()
            
        case .heritage:
            publisher = HeritageService.shared.get()
                .map { (response: HeritageResponse) in response.results as [any Place] }
                .eraseToAnyPublisher()
            
        case .bicycle:
            publisher = BicycleService.shared.get()
                .map { $0.data as [any Place] }
                .eraseToAnyPublisher()
            
        case .wifi:
            let service = WIFIService()
            publisher = service.get()
                .map { $0.data as [any Place] }
                .eraseToAnyPublisher()
            
        case .restaurant, .accommodation, .parking:
            // These APIs will be integrated in Phase 3+
            publisher = Just([any Place]())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    if case .failure(let error) = completion {
                        print("❤️ PlaceList fetch error: \(error)")
                        self?.emptyLabel.isHidden = false
                        self?.emptyLabel.text = "common.error".localized
                    }
                },
                receiveValue: { [weak self] places in
                    self?.places = places
                    self?.tableView.reloadData()
                    self?.emptyLabel.isHidden = !places.isEmpty
                }
            )
            .store(in: &subscription)
    }
}

// MARK: - UITableView

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceListCell.identifier, for: indexPath) as! PlaceListCell
        cell.configure(with: places[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let detailVC = PlaceDetailViewController(place: place)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
