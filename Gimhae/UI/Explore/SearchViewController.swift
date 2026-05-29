//
//  SearchViewController.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit
import AddThen

final class SearchViewController: BaseViewController {
    
    private var allPlaces: [any Place] = []
    private var filteredPlaces: [any Place] = []
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "map.search".localized
        bar.delegate = self
        bar.searchBarStyle = .minimal
        return bar
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(PlaceListCell.self, forCellReuseIdentifier: PlaceListCell.identifier)
        tv.rowHeight = 96
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    private lazy var emptyLabel = UILabel().then {
        $0.text = "common.noResults".localized
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAllData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "map.search".localized
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func loadAllData() {
        // Load tourism spots
        TourismService.shared.getTourismSpots(page: 1, pageunit: 100)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    self?.allPlaces.append(contentsOf: response.results)
                    self?.filteredPlaces = self?.allPlaces ?? []
                    self?.tableView.reloadData()
                }
            )
            .store(in: &subscription)
        
        // Load festivals
        FestivalService().getFestivals(page: 1)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    self?.allPlaces.append(contentsOf: response.results)
                    self?.filterPlaces(self?.searchBar.text ?? "")
                }
            )
            .store(in: &subscription)
        
        // Load heritage
        HeritageService.shared.get()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    self?.allPlaces.append(contentsOf: response.results)
                    self?.filterPlaces(self?.searchBar.text ?? "")
                }
            )
            .store(in: &subscription)
    }
    
    private func filterPlaces(_ query: String) {
        if query.isEmpty {
            filteredPlaces = allPlaces
        } else {
            filteredPlaces = allPlaces.filter { place in
                place.placeName.localizedCaseInsensitiveContains(query) ||
                (place.placeAddress?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
        tableView.reloadData()
        emptyLabel.isHidden = !filteredPlaces.isEmpty || query.isEmpty
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPlaces(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceListCell.identifier, for: indexPath) as! PlaceListCell
        cell.configure(with: filteredPlaces[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = filteredPlaces[indexPath.row]
        let detail = PlaceDetailViewController(place: place)
        navigationController?.pushViewController(detail, animated: true)
    }
}
