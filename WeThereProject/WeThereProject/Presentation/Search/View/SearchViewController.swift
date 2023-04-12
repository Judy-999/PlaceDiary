//
//  SearchViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/23. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift

final class SearchViewController: UIViewController {
    @IBOutlet private var searchTableView: UITableView!
    
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    private var filteredPlaces = [Place]()
    private var searchText = String()
    private var isSearching: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive == true
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    required init?(viewModel: SearchViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupTableView()
        loadPlaces()
        bind()
    }
    
    private func bind() {
        viewModel.places
            .subscribe { [weak self] _ in
                self?.searchTableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    private func loadPlaces() {
        viewModel.loadPlaceData(disposeBag)
    }
    
    private func setupTableView() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = PlaceInfo.Search.placeHolder
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        setupNavigationItem(searchController)
    }
    
    private func setupNavigationItem(_ searchController: UISearchController) {
        self.navigationItem.searchController = searchController
        self.navigationItem.title = PlaceInfo.Search.title
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - Table view data source
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    private func initializeTableView(with coment: String) {
        let emptyLabel = UILabel(frame: CGRect(x: .zero,
                                               y: .zero,
                                               width: view.bounds.size.width,
                                               height: view.bounds.size.height))
        emptyLabel.text = coment
        emptyLabel.textAlignment = NSTextAlignment.center
        searchTableView.backgroundView = emptyLabel
        searchTableView.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = .none
        
        if isSearching {
            if filteredPlaces.isEmpty {
                initializeTableView(with: PlaceInfo.Search.noSearch)
            }
            
            return filteredPlaces.count
        } else {
            let places = viewModel.places.value
            if places.isEmpty {
                initializeTableView(with: PlaceInfo.Search.emptySearch)
            }
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell",
                                                 for: indexPath) as? SearchResultCell ?? SearchResultCell()
        
        if isSearching {
            let searchPlace = filteredPlaces[indexPath.row]
            let name = NSMutableAttributedString(string: searchPlace.name)
            name.addAttribute(.foregroundColor,
                              value: Color.highlight,
                              range: (searchPlace.name as NSString).range(of: searchText))
            
            let address = NSMutableAttributedString(string: searchPlace.location)
            address.addAttribute(.foregroundColor,
                                 value: Color.highlight,
                                 range: (searchPlace.location as NSString).range(of: searchText))
            
            cell.nameLabel.attributedText = name
            cell.locationLabel.attributedText = address
            
        } else {
            let place = viewModel.places.value[indexPath.row]
            cell.nameLabel.text = place.name
            cell.locationLabel.text = place.location
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let places = viewModel.places.value
        let selectedPlaces: [Place] = isSearching ? filteredPlaces : places

        if let place = places.first(where: { $0.name == selectedPlaces[indexPath.row].name }) {
            viewModel.showPlaceDetail(place)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        let places = viewModel.places.value
        searchText = text
        filteredPlaces = places.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText) ||
            $0.coment.localizedCaseInsensitiveContains(searchText)
        }
        searchTableView.reloadData()
    }
}
