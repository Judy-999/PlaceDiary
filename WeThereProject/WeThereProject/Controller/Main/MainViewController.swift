//
//  MainPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/14. --> Refacted on 2022/12/15
//

import UIKit

final class MainViewController: UIViewController {
    private enum ViewMode: Int {
        case all
        case group
        case category
    }
    
    private var categoryItems = [String]()
    private var groupItems = [String]()
    private var placeType: [ViewMode: [String]] = [.all: [""]]
    private var places = [Place]() {
        didSet {
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var placeTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        setupClassification()
        setupPlaces()
        placeTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaceData()
        loadClassification()
        configureRefreshControl()
    }
    
    private func setupPlaces() {
        places = PlaceDataManager.shared.getPlaces()
    }
    
    private func configureRefreshControl() {
        placeTableView.refreshControl = UIRefreshControl()
        placeTableView.refreshControl?.addTarget(self,
                                                 action: #selector(pullToRefresh),
                                                 for: .valueChanged)
    }

    @objc private func pullToRefresh(_ refresh: UIRefreshControl) {
        placeTableView.reloadData()
        refresh.endRefreshing()
    }

    private func loadPlaceData() {
        PlaceDataManager.shared.loadPlaces() { [weak self] result in
            switch result {
            case .success(let places):
                self?.places = places
            case .failure(let failure):
                self?.showAlert("실패", failure.localizedDescription)
            }
        }
    }

    private func loadClassification() {
        PlaceDataManager.shared.loadClassification { [weak self] result in
            switch result {
            case .success((let categoryItems, let groupItems)):
                self?.categoryItems = categoryItems
                self?.groupItems = groupItems
                self?.placeType[.category] = categoryItems
                self?.placeType[.group] = groupItems
            case .failure(let error):
                self?.showAlert("실패", error.localizedDescription)
            }
        }
    }
    
    private func setupClassification() {
        let calssification: (categoryItems: [String], groupItems: [String])
        = PlaceDataManager.shared.getClassification()
        categoryItems = calssification.categoryItems
        groupItems = calssification.groupItems
        placeType[.category] = calssification.categoryItems
        placeType[.group] = calssification.groupItems
    }

    private func filteredPlaces(at section: Int) -> [Place] {
        let select = segmentedControl.selectedSegmentIndex
        guard let mode = ViewMode(rawValue: select),
              let placeList = placeType[mode] else { return places }
        
        switch mode {
        case .all:
            return places
        case .group:
            return places.filter { $0.group == placeList[section] }
        case .category:
            return places.filter { $0.category == placeList[section] }
        }
    }
    
    private func setupInitialView() {
        let emptyLabel = UILabel()
        emptyLabel.frame = CGRect(x: .zero,
                                  y: .zero,
                                  width: view.bounds.width,
                                  height: view.bounds.height)
        emptyLabel.text = PlaceInfo.Main.empty
        emptyLabel.textAlignment = .center
        placeTableView.backgroundView = emptyLabel
        placeTableView.separatorStyle = .none
    }

    private func deletePlace(_ indexPath: IndexPath) {
        let places = filteredPlaces(at: indexPath.section)
        let placeName = places[indexPath.row].name
        let deletAlert = UIAlertController(title: PlaceInfo.Main.delete,
                                           message: placeName + PlaceInfo.Main.confirmDelete,
                                           preferredStyle: .actionSheet)
        let okAlert = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            FirestoreManager.shared.deletePlace(placeName) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let failure):
                    self?.showAlert("실패", failure.errorDescription)
                }
            }
            
            StorageManager.shared.deleteImage(name: placeName) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let failure):
                    self?.showAlert("실패", failure.errorDescription) 
                }
            }
     
            guard let removedIndex = self?.places.firstIndex(where: { $0.name == placeName }) else { return }
            
            self?.places.remove(at: removedIndex)
            self?.placeTableView.deleteRows(at: [indexPath], with: .fade)
        }
                                    
        deletAlert.addAction(Alert.cancel)
        deletAlert.addAction(okAlert)
       
        present(deletAlert, animated: true)
    }
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        placeTableView.reloadData()
    }
    
    @IBAction private func sortButtonTapped(_ sender: UIBarItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: Sort.rating, style: .default) { _ in
            self.places.sort(by: { $0.rating > $1.rating })
        })

        alert.addAction(UIAlertAction(title: Sort.alphabetical, style: .default) { _ in
            self.places.sort(by: { $0.name < $1.name })
        })

        alert.addAction(UIAlertAction(title: Sort.latestDate, style: .default) { _ in
            self.places.sort(by: { $0.date > $1.date })
        })
        
        alert.addAction(UIAlertAction(title: Sort.favorit, style: .default) { _ in
            let favoritPlalces = self.places.filter { $0.isFavorit == true }
            self.places = favoritPlalces
        })
        
        alert.addAction(Alert.cancel)
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.info.identifier {
            guard let infoViewContorller = segue.destination as? PlaceInfoTableViewController,
                  let cell = sender as? UITableViewCell,
                  let indexPath = placeTableView.indexPath(for: cell) else { return }

            let places = filteredPlaces(at: indexPath.section)
            infoViewContorller.getPlaceInfo(places[indexPath.row])
        }
    }
}

// MARK: - TableViewDataSource & TableViewDelegate
extension MainViewController: UITableViewDataSource,  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        let select = segmentedControl.selectedSegmentIndex
        guard let mode = ViewMode(rawValue: select),
              let placeList = placeType[mode] else { return .zero }
        
        return placeList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let select = segmentedControl.selectedSegmentIndex
        guard let mode = ViewMode(rawValue: select),
              let placeList = placeType[mode] else { return nil }
        
        return placeList[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard places.isEmpty == false else {
            setupInitialView()
            return .zero
        }
        
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = .none
        
        return filteredPlaces(at: section).count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell",
                                                 for: indexPath) as? PlaceCell ?? PlaceCell()
        let places = filteredPlaces(at: indexPath.section)
        cell.configure(with: places[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.contentView.backgroundColor = Color.partialHighlight
        headerView.textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePlace(indexPath)
        }
    }
}


fileprivate enum Sort {
    static let rating = "별점 높은 순"
    static let alphabetical = "가나다 순"
    static let latestDate = "방문 날짜 순"
    static let favorit = "즐겨찾기만 보기"
}

