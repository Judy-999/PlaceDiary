//
//  MainPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/14. --> Refacted on 2022/12/15
//

import UIKit

class MainPlaceViewController: UIViewController, ImageDelegate {
    private var newUapdate: Bool = true
    private var sectionNum: Int = 1
    private var sectionName: [String] = [""]
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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var placeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaceData()
        downloadList()
        
        placeTableView.refreshControl = UIRefreshControl()
        placeTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        placeTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newUpdate), name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
    }

    @objc func newUpdate(_ notification: Notification){
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
                    sectionIndex = sectionName.firstIndex(of: removePlace!.group)
                    let cellData = places.filter({$0.group == removePlace!.group})
                    index = cellData.firstIndex(where: {$0.name == deleteName})
                case 2:
                    let removePlace = places.first(where: {$0.name == deleteName})
                    sectionIndex = sectionName.firstIndex(of: removePlace!.category)
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

    // 카테고리와 그룹 정보를 받아오는 함수
    func downloadList(){
        FirestoreManager.shared.loadClassification { categoryItems, groupItems in
            self.categoryItem = categoryItems
            self.groupItem = groupItems
        }
    }
    
    // 장소 이미지 리스트를 새로운 리스트로 변경하는 함수
    func updateImage(_ newImageList: [String : UIImage]){
        placeImages = newImageList
    }
        
    // 다른 페이지로 장소 정보와 이미지를 넘겨주는 함수
    func passData(){
        let searchNav = tabBarController?.viewControllers![1] as! UINavigationController
        let searchController = searchNav.topViewController as! SearchTableViewController
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
    
    // 선택한 장소 보기별로 장소 리스트를 변경해주는 함수
    func getPlaceList(index: IndexPath) -> [Place] {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return places
        case 1:
            return places.filter({$0.group == sectionName[index.section]})
        case 2:
            return places.filter({$0.category == sectionName[index.section]})
        default:
            return places
        }
    }
    
    // ImageDelegat 프로토콜
    func didImageDone(newData: Place, image: UIImage) {
        placeImages.updateValue(image, forKey: newData.name) 
    }
   
    // 테이블 뷰를 끌어내려서 로딩
    @objc func pullToRefresh(_ refresh: UIRefreshControl){
        placeTableView.reloadData()
        refresh.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadList()
        placeTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if newUapdate{
            passData()
            newUapdate = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func deleteConfirm(_ indexPath: IndexPath){
        let cellData = getPlaceList(index: indexPath)
        let deletAlert = UIAlertController(title: "장소 삭제", message: cellData[indexPath.row].name + "(을)를 삭제하시겠습니까?", preferredStyle: .actionSheet)
        let okAlert = UIAlertAction(title: "삭제", style: .destructive){ UIAlertAction in
            let removePlace = cellData[indexPath.row].name
            
            FirestoreManager.shared.deletePlace(removePlace)
            StorageManager.shared.deleteImage(name: removePlace)
     
            let removeDataIndex = self.places.firstIndex(where: {$0.name == cellData[(indexPath as NSIndexPath).row].name})!
            self.places.remove(at: removeDataIndex)
            
            self.newUapdate = true
            
            self.placeTableView.deleteRows(at: [indexPath], with: .fade)
            self.placeTableView.reloadData()
        }
                                    
        deletAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        deletAlert.addAction(okAlert)
       
        self.present(deletAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func sortBtn(_ sender: UIBarItem){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "별점 높은 순", style: .default) { _ in
            self.places.sort(by: {$0.rate > $1.rate})
        })

        alert.addAction(UIAlertAction(title: "가나다 순", style: .default) { _ in
            self.places.sort(by: {$0.name < $1.name})
        })

        alert.addAction(UIAlertAction(title: "방문 날짜 순", style: .default) { _ in
            self.places.sort(by: {$0.date > $1.date})
        })
        
        alert.addAction(UIAlertAction(title: "즐겨찾기만 보기", style: .default) { _ in
            let favoritPlalces = self.places.filter({$0.isFavorit == true})
            self.places = favoritPlalces
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .destructive))
        present(alert, animated: true)
    }

    @IBAction func sgChangeListType(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            sectionNum = 1
            sectionName = [""]
            placeTableView.reloadData()
        case 1:
            sectionNum = groupItem.count
            sectionName.removeAll()
            for group in groupItem{
                sectionName.append(group)
            }
            placeTableView.reloadData()
        case 2:
            sectionNum = categoryItem.count
            sectionName.removeAll()
            for name in categoryItem{
                sectionName.append(name)
            }
            placeTableView.reloadData()
        default:
            sender.selectedSegmentIndex = 0
        }
    }

    @IBAction func clickHotButton(_ sender: UIButton){
        let place = getPlaceList(index: [sectionNum, sender.tag])
        let selectedData = place[sender.tag]
        
        if selectedData.isFavorit {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        }else{
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
        FirestoreManager.shared.updateFavorit(!selectedData.isFavorit, placeName: selectedData.name)
        placeTableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgPlaceInfo"{
            let cell = sender as! UITableViewCell
            let indexPath = self.placeTableView.indexPath(for: cell)! as IndexPath
            let infoView = segue.destination as! PlaceInfoTableViewController
            let sectionPlaces = getPlaceList(index: indexPath)
            let selectedData : Place!
            if segmentedControl.selectedSegmentIndex == 0 {
                selectedData = sectionPlaces[indexPath.row]
            } else {
                selectedData = sectionPlaces[indexPath.row - 1]
            }
            
            infoView.imgDelegate = self
            
            if let placeImage = placeImages[selectedData.name] {
                infoView.getPlaceInfo(selectedData, image: placeImage)
            }else{
                if selectedData.hasImage{
                    infoView.downloadImgInfo(selectedData)
                }else{
                    infoView.getPlaceInfo(selectedData, image: UIImage(named: "pdicon")!)
                }
            }
        }
        if segue.identifier == "sgAddPlace"{
            let addView = segue.destination as! AddPlaceTableViewController
            addView.nowPlaceData = places
        }
    }
}

// MARK: - TableViewDataSource & TableViewDelegate
extension MainPlaceViewController: UITableViewDataSource,  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNum
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if places.count == 0 {
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                emptyLabel.text = "장소를 추가해보세요!"
                emptyLabel.textAlignment = NSTextAlignment.center
                tableView.backgroundView = emptyLabel
                tableView.separatorStyle = .none
                return 0
            } else {
                tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                tableView.backgroundView = .none
                return places.count
            }
        case 1:
            let filteredArray = places.filter({$0.group == sectionName[section]})
            return filteredArray.count
        case 2:
            let filteredArray = places.filter({$0.category == sectionName[section]})
            return filteredArray.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        
        let cellData = getPlaceList(index: indexPath)
        let cellPlace : Place!
        if segmentedControl.selectedSegmentIndex == 0 {
            cellPlace = cellData[indexPath.row]
        } else {
            if indexPath.row == 0{
                cellPlace = cellData[indexPath.row]
            } else {
                cellPlace = cellData[indexPath.row - 1]
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        cell.lblPlaceDate.text = formatter.string(from: cellPlace.date)
        cell.lblPlaceName.text = cellPlace.name
        
        cell.lblPlaceInfo.text = cellPlace.group + " ∙ " + cellPlace.category + " ∙ " + cellPlace.rate + " 점"
        cell.imgPlace.image = UIImage(named: "pdicon")
    
        cell.btnFavorit.tag = indexPath.row
        
        cellPlace.isFavorit ? cell.btnFavorit.setImage(UIImage(systemName: "heart.fill"), for: .normal) :
        cell.btnFavorit.setImage(UIImage(systemName: "heart"), for: .normal)
        
        if cellPlace.hasImage{
            if let placeImage = placeImages[cellPlace.name] {
                cell.imgPlace.image = placeImage
            } else {
                DispatchQueue.main.async { [self] in
                    if let updateCell = tableView.cellForRow(at: indexPath) as? PlaceCell {
                        StorageManager.shared.getImage(name: cellPlace.name) { photo in
                            if let photo = photo {
                                updateCell.imgPlace.image = photo
                                self.placeImages.updateValue(photo, forKey: cellPlace.name)
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteConfirm(indexPath)
        }
    }
}
