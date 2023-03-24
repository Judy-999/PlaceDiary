//
//  SearchViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/23. --> Refacted on 2022/12/15
//

import UIKit

final class SearchViewController: UIViewController {
    @IBOutlet private var searchTableView: UITableView!
    
    private var filteredPlaces = [Place]()
    private var searchText = String()
    private var places = [Place]()
    private var isSearching: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive == true
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }

    override func viewWillAppear(_ animated: Bool) {
        setupPlaces()
        searchTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaces()
        setupSearchController()
        setupTableView()
    }
    
    private func setupPlaces() {
        places = PlaceDataManager.shared.getPlaces()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.serach.identifier {
            guard let infoView = segue.destination as? PlaceInfoTableViewController,
                  let cell = sender as? UITableViewCell,
                  let indexPath = searchTableView.indexPath(for: cell) else { return }
            
            let selectedPlaces: [Place] = isSearching ? filteredPlaces : places

            if let place = places.first(where: { $0.name == selectedPlaces[indexPath.row].name }) {
                infoView.getPlaceInfo(place)
            }
        }
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
            
            cell.lblName.attributedText = name
            cell.lblLocation.attributedText = address
            
        } else {
            let place = places[indexPath.row]
            cell.lblName.text = place.name
            cell.lblLocation.text = place.location
        }
        
        return cell
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        
        searchText = text
        filteredPlaces = places.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText) ||
            $0.coment.localizedCaseInsensitiveContains(searchText)
        }
        searchTableView.reloadData()
    }
}
