//
//  MainPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/14. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift

final class MainViewController: UIViewController {
    private enum ViewMode: Int {
        case all
        case group
        case category
    }
    
    private var classification = Classification()
    private var placeType: [ViewMode: [String]] = [.all: [""]]
    private var places = [Place]() {
        didSet {
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
        }
    }
    private let mainViewModel = MainViewModel()
    private let imageRepository = ImageRepository()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var placeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaceData()
        loadClassification()
        configureRefreshControl()
        bind()
    }
    
    private func bind() {
        mainViewModel.places
            .subscribe(onNext: { [weak self] places in
                self?.places = places
            })
            .disposed(by: disposeBag)
        
        mainViewModel.classification
            .do(onNext: { [weak self] classification in
                self?.placeType[.category] = classification.category
                self?.placeType[.group] = classification.group
            })
            .subscribe(onNext: { [weak self] classification in
                self?.classification = classification
            })
            .disposed(by: disposeBag)
                
        mainViewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(nil, message)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        placeTableView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] _ in
                self?.loadPlaceData()
            })
            .disposed(by: disposeBag)
        
        mainViewModel.refreshing
            .subscribe(onNext: { [weak self] isRefreshing in
                if isRefreshing == false {
                    self?.placeTableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }

    private func loadPlaceData() {
        mainViewModel.loadPlaceData(disposeBag)
    }
        
    private func loadClassification() {
        mainViewModel.loadClassification(disposeBag)
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
            self?.mainViewModel.deletePlace(placeName, self!.disposeBag)
            
            //TODO: 이미지 삭제 storage 업데이트
     
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
    
    @IBAction private func addPlaceButtonTapped(_ sender: UIBarButtonItem) {
        guard let addViewController = storyboard?.instantiateViewController(identifier: "AddViewController", creator: { creater in
            let addViewController = AddPlaceTableViewController(viewModel: self.mainViewModel,
                                                                coder: creater)
            return addViewController
        }) else { return }
        
        navigationController?.pushViewController(addViewController, animated: true)
    }
}

// MARK: - TableViewDataSource & TableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.configure(with: places[indexPath.row], imageRepository)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let places = filteredPlaces(at: indexPath.section)
        let selectedPlace = places[indexPath.row]
        
        guard let infoViewController = storyboard?.instantiateViewController(identifier: "InfoViewController", creator: { creater in
            let infoViewController = PlaceInfoTableViewController(place: selectedPlace,
                                                                  viewModel: self.mainViewModel,
                                                                  coder: creater)
            return infoViewController
        }) else { return }
        
        navigationController?.pushViewController(infoViewController, animated: true)
    }
}


fileprivate enum Sort {
    static let rating = "별점 높은 순"
    static let alphabetical = "가나다 순"
    static let latestDate = "방문 날짜 순"
    static let favorit = "즐겨찾기만 보기"
}

