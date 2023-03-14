//
//  MainPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/14. --> Refacted on 2022/12/15
//

import UIKit

class MainViewController: UIViewController, ImageDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var placeTableView: UITableView!
    
    private var newUapdate: Bool = true
    private var sectionNames: [String] = [""]
    private var categoryItem = [String]()
    private var groupItem = [String]()
    private var placeImages = [String : UIImage]()
    private var places = [Place]() {
        didSet {
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadClassification()
        placeTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if newUapdate {
            passData()
            newUapdate = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaceData()
        loadClassification()
        configureRefreshControl()
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newUpdate),
                                               name: NSNotification.Name(rawValue: "newPlaceUpdate"),
                                               object: nil)
    }
    
    private func configureRefreshControl() {
        placeTableView.refreshControl = UIRefreshControl()
        placeTableView.refreshControl?.addTarget(self,
                                                 action: #selector(pullToRefresh),
                                                 for: .valueChanged)
    }
    
    // 테이블 뷰를 끌어내려서 로딩
    @objc private func pullToRefresh(_ refresh: UIRefreshControl) {
        placeTableView.reloadData()
        refresh.endRefreshing()
    }

    @objc private func newUpdate(_ notification: Notification){
        newUapdate = true
        if notification.object != nil{
            let data = notification.object as! Place
            if data.newImg != nil{ // 새로운 이미지 추가
                placeImages.updateValue(data.newImg!, forKey: data.name)
            }else{  // 장소 삭제 
                let deleteName = data.name
                var index: Int!
                var sectionIndex: Int!
                
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    index = places.firstIndex(where: {$0.name == deleteName})
                    sectionIndex = 0
                case 1:
                    let removePlace = places.first(where: {$0.name == deleteName})
                    sectionIndex = sectionNames.firstIndex(of: removePlace!.group)
                    let cellData = places.filter({$0.group == removePlace!.group})
                    index = cellData.firstIndex(where: {$0.name == deleteName})
                case 2:
                    let removePlace = places.first(where: {$0.name == deleteName})
                    sectionIndex = sectionNames.firstIndex(of: removePlace!.category)
                    let cellData = places.filter({$0.category == removePlace!.category})
                    index = cellData.firstIndex(where: {$0.name == deleteName})
                default:
                    index = places.firstIndex(where: {$0.name == deleteName})
                    sectionIndex = 0
                }
                tableView(placeTableView, commit: .delete, forRowAt: [sectionIndex, index])
            }
        }
    }
    
    private func loadPlaceData() {
        FirestoreManager.shared.loadData() { places in
            self.places = places
        }
    }

    private func loadClassification() {
        FirestoreManager.shared.loadClassification { categoryItems, groupItems in
            self.categoryItem = categoryItems
            self.groupItem = groupItems
        }
    }
    
    // 장소 이미지 리스트를 새로운 리스트로 변경하는 함수
    func updateImage(_ newImageList: [String : UIImage]) {
        placeImages = newImageList
    }
        
    // 다른 페이지로 장소 정보와 이미지를 넘겨주는 함수
    private func passData() {
        let searchNav = tabBarController?.viewControllers![1] as! UINavigationController
        let searchController = searchNav.topViewController as! SearchViewController
        let calendarNav = tabBarController?.viewControllers![2] as! UINavigationController
        let calendarController = calendarNav.topViewController as! CalendarController
        let mapNav = tabBarController?.viewControllers![3] as! UINavigationController
        let mapController = mapNav.topViewController as! MapViewController
        let settingNav = tabBarController?.viewControllers![4] as! UINavigationController
        let settingController = settingNav.topViewController as! SettingTableController
        
        searchController.setData(places, images: placeImages)
        mapController.getPlace(places, images: placeImages)
        calendarController.getDate(places, images: placeImages)
        settingController.getPlaces(places)
    }
    
    private func findCurrentPlace(index: IndexPath) -> Place {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return places[index.row]
        case 1:
            let placeList = places.filter { $0.group == sectionNames[index.section] }
            return placeList[index.row]
        case 2:
            let placeList = places.filter { $0.category == sectionNames[index.section] }
            return placeList[index.row]
        default:
            return places[index.row]
        }
    }
    
    private func setupInitialView() {
        let emptyLabel = UILabel()
        emptyLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        emptyLabel.text = "장소를 추가해보세요!"
        emptyLabel.textAlignment = .center
        placeTableView.backgroundView = emptyLabel
        placeTableView.separatorStyle = .none
    }
    
    // ImageDelegat 프로토콜
    func didImageDone(newData: Place, image: UIImage) {
        placeImages.updateValue(image, forKey: newData.name) 
    }

    private func deletePlace(_ indexPath: IndexPath){
        let place = findCurrentPlace(index: indexPath)
        let placeName = place.name
        let deletAlert = UIAlertController(title: "장소 삭제",
                                           message: "\(placeName)(을)를 삭제하시겠습니까?",
                                           preferredStyle: .actionSheet)
        let okAlert = UIAlertAction(title: "삭제", style: .destructive) { _ in
            FirestoreManager.shared.deletePlace(placeName)
            StorageManager.shared.deleteImage(name: placeName)
     
            guard let removedIndex = self.places.firstIndex(where: { $0.name == placeName }) else { return }
            
            self.places.remove(at: removedIndex)
            self.placeTableView.deleteRows(at: [indexPath], with: .fade)
            self.newUapdate = true
        }
                                    
        deletAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        deletAlert.addAction(okAlert)
       
        present(deletAlert, animated: true)
    }
    
    @IBAction private func sortButtonTapped(_ sender: UIBarItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "별점 높은 순", style: .default) { _ in
            self.places.sort(by: { $0.rate > $1.rate })
        })

        alert.addAction(UIAlertAction(title: "가나다 순", style: .default) { _ in
            self.places.sort(by: { $0.name < $1.name })
        })

        alert.addAction(UIAlertAction(title: "방문 날짜 순", style: .default) { _ in
            self.places.sort(by: { $0.date > $1.date })
        })
        
        alert.addAction(UIAlertAction(title: "즐겨찾기만 보기", style: .default) { _ in
            let favoritPlalces = self.places.filter { $0.isFavorit == true }
            self.places = favoritPlalces
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .destructive))
        present(alert, animated: true)
    }

    @IBAction private func segmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sectionNames = [""]
        case 1:
            sectionNames = groupItem
        case 2:
            sectionNames = categoryItem
        default:
            break
        }
        
        placeTableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgPlaceInfo" {
            guard let infoViewContorller = segue.destination as? PlaceInfoTableViewController,
                  let cell = sender as? UITableViewCell,
                  let indexPath = placeTableView.indexPath(for: cell) else { return }

            let selectedPlace = findCurrentPlace(index: indexPath)
            
            infoViewContorller.getPlaceInfo(selectedPlace)
            infoViewContorller.imgDelegate = self
        }
        
        if segue.identifier == "sgAddPlace" {
            guard let addViewController = segue.destination as? AddPlaceTableViewController else { return }
            addViewController.places = places
        }
    }
}

// MARK: - TableViewDataSource & TableViewDelegate
extension MainViewController: UITableViewDataSource,  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard places.isEmpty == false else {
            setupInitialView()
            return 0
        }
        
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = .none
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return places.count
        case 1:
            let filteredArray = places.filter { $0.group == sectionNames[section] }
            return filteredArray.count
        case 2:
            let filteredArray = places.filter { $0.category == sectionNames[section] }
            return filteredArray.count
        default:
            return places.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as? PlaceCell ?? PlaceCell()
        let place = findCurrentPlace(index: indexPath)
 
        cell.configure(with: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        headerView.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePlace(indexPath)
        }
    }
}
