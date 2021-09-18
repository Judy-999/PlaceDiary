//
//  MainPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView

import FirebaseStorage

let Uid = UIDevice.current.identifierForVendor!.uuidString

class MainPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    private let loadingView = UIView();
    var newUapdate = true
    var loadingCount = 0
    var sectionNum = 1
    var sgNum = 0
    var sectionName = [""]
    var categoryItem = [String]()
    var groupItem = [String]()
    var placeImages = [String : UIImage]()
    
    
    lazy var cache: NSCache<AnyObject, UIImage> = NSCache()
    
    var places = [PlaceData]() {
        didSet {
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
        }
    }
    
    private var service: PlaceService?
       private var allPlaces = [PlaceData]() {
        didSet {
            DispatchQueue.main.async {
                self.places = self.allPlaces
            }
        }
    }
    
    @IBOutlet var placeTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("이건 프로그래밍 방식이래요. 뭐가 다른건지 : " + UIDevice.current.identifierForVendor!.uuidString)
       

        loadPlaceData()
        downloadList()
        
        placeTableView.refreshControl = UIRefreshControl()    //새로고침
        placeTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        placeTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(newUpdate), name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
        
    }

    @objc func newUpdate(_ notification: Notification){
        newUapdate = true
        if notification.object != nil{
            let data = notification.object as! PlaceData
            if data.newImg != nil{
                placeImages.updateValue(data.newImg!, forKey: data.name)
            }else{
                let deleteName = data.name
                var index: Int!
                var sectionIndex: Int!
                switch sgNum {
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
    
    func loadPlaceData() {
        service = PlaceService()
        service?.get(collectionID: Uid) { places in
            self.allPlaces = places
        }
    }

    func downloadList(){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.categoryItem = (document.get("items") as? [String])!
                self.groupItem = (document.get("group") as? [String])!
            } else {
                print("Document does not exist")
                let basicCategory: [String: [String]] = [
                    "items": ["카페", "음식점", "디저트", "베이커리", "액티비티", "야외"],
                    "group": ["기본", "친구", "가족", "혼자"]
                ]
                self.db.collection("category").document(Uid).setData(basicCategory) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.downloadList()
                    }
                }
            }
        }
    }
        
   func godata(){
        let mapController = self.tabBarController?.viewControllers![3] as! MapViewController
        let searchNav = self.tabBarController?.viewControllers![1] as! UINavigationController
        let searchController = searchNav.topViewController as! SearchTableViewController
        let calendarNav = self.tabBarController?.viewControllers![2] as! UINavigationController
        let calendarController = calendarNav.topViewController as! CalendarController
        let settingNav = self.tabBarController?.viewControllers![4] as! UINavigationController
        let settingController = settingNav.topViewController as! SettingTableController
        
        searchController.setData(places, images: placeImages)
        mapController.getPlace(places, images: placeImages)
        calendarController.getDate(places, images: placeImages)
        settingController.getPlaces(places)
    }
    
    func getPlaceList(sectionNum: Int, index: IndexPath) -> [PlaceData]{
        switch sgNum {
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
    
    @objc func pullToRefresh(_ refresh: UIRefreshControl){
        placeTableView.reloadData()
        refresh.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadList()
        placeTableView.reloadData()  //목록 재로딩
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if newUapdate{
            godata()
            newUapdate = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source

    //테이블 섹션의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNum
    }
    
    //섹션 당 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sgNum == 0{
            return places.count
        }else if sgNum == 1{
            let filteredArray = places.filter({$0.group == sectionName[section]})
            return filteredArray.count
        }else{
            let filteredArray = places.filter({$0.category == sectionName[section]})
            return filteredArray.count
        }
    }
    
    // Returns the title of the section.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        
        let cellData = getPlaceList(sectionNum: sgNum, index: indexPath)
        
        
        cell.lblPlaceName.text = cellData[indexPath.row].name
        cell.lblPlaceLocation.text = cellData[indexPath.row].location
        
        if places[indexPath.row].rate != "0.0"{
            cell.lblPlaceInfo.text = cellData[indexPath.row].rate + "점"
        }else{
            cell.lblPlaceInfo.text = "가보고 싶어요!"
        }
        
        cell.imgPlace.image = UIImage(named: "wethere.jpeg")
    
        
        if placeImages[cellData[indexPath.row].name] != nil {
        /// 해당 row에 해당되는 부분이 캐시에 존재하는 경우
           // cell.imgPlace.image = cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject)
            cell.imgPlace.image = placeImages[cellData[indexPath.row].name]
        } else { /// 해당 row에 해당되는 부분이 캐시에 존재하지 않는 경우
            getImage(place: places[indexPath.row]){ photo in
            if photo != nil {
                /// 이미지가 성공적으로 다운 > imageView에 넣기 위해 main thread로 전환 (주의: background가 아닌 main thread)
                DispatchQueue.main.async { [self] in
                    /// 해당 셀이 보여지게 될때 imageView에 할당하고 cache에 저장
                    /// 이미지를 업데이트하기전에 화면에 셀이 표시되는지 확인 (확인하지 않을경우, 스크롤하는 동안 이미지가 각 셀에서 불필요하게 재사용)
                   // cell.imgPlace.image = photo
                   
                
                    if let updateCell = tableView.cellForRow(at: indexPath) as? PlaceCell{
                        updateCell.imgPlace.image = photo
                       // self.cache.setObject(photo!, forKey: (indexPath as NSIndexPath).row as AnyObject)
                        placeImages.updateValue(photo!, forKey: self.places[indexPath.row].name)
                        }
                    }
                }
            }
        }
        
        return cell
        
    /*    if placeImages[cellData[indexPath.row].name] != nil{
            cell.imgPlace.image = placeImages[cellData[indexPath.row].name]
        }else{
            cell.imgPlace.image = UIImage(named: "wethere.jpeg")
            
            cell.getImage(place: places[indexPath.row]){ photo in
                if photo != nil {
                    DispatchQueue.main.async { [self] in
                        cell.imgPlace.image = photo
                        placeImages.updateValue(photo!, forKey: self.places[indexPath.row].name)
                     }
                }
            }
        }
        
            
        cell.lblPlaceName.text = cellData[indexPath.row].name
        cell.lblPlaceLocation.text = cellData[indexPath.row].location
        
        if places[indexPath.row].rate != "0.0"{
            cell.lblPlaceInfo.text = cellData[indexPath.row].rate + "점"
        }else{
            cell.lblPlaceInfo.text = "가보고 싶어요!"
        }
        
        print("cellForRowAt : \(indexPath.row)")
        
        return cell
 
 */
    }
    
    
    
    func getImage(place: PlaceData, completion: @escaping (UIImage?) -> ()) {
        let fileName = place.name
        if place.image == true {
            let islandRef = storage.reference().child(Uid + "/" + fileName)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    completion(downloadImg)
                    print("image download!!!" + fileName)
                } else {
                        completion(nil)
                }
            }
        }else{
            let basicImg = UIImage(named: "wethere.jpeg")
            completion(basicImg)
        }
    }
    

 

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    //셀 삭제
            // Delete the row from the data source
            
            let cellData = getPlaceList(sectionNum: sgNum, index: indexPath)
            let removePlace = cellData[(indexPath as NSIndexPath).row].name as String
            
            
            db.collection(Uid).document(removePlace).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            storage.reference().child(Uid + "/" + removePlace).delete { error in
                if let error = error {
                    print("Error removing image: \(error)")
                } else {
                    print("Image successfully removed!")
                }
              }
     
      
           let removeDataIndex = places.firstIndex(where: {$0.name == cellData[(indexPath as NSIndexPath).row].name})!
            places.remove(at: removeDataIndex)
            
            newUapdate = true
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            placeTableView.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func sortBtn(_ sender: UIBarItem){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "별점 높은 순", style: .default) { _ in
            self.places.sort(by: {$0.rate > $1.rate})
        })

        alert.addAction(UIAlertAction(title: "가나다 순", style: .default) { _ in
            self.places.sort(by: {$0.name < $1.name})
        })
        
        alert.addAction(UIAlertAction(title: "방문 횟수 순", style: .default) { _ in
            self.places.sort(by: {$0.count > $1.count})
        })
        
        alert.addAction(UIAlertAction(title: "방문 날짜 순", style: .default) { _ in
            self.places.sort(by: {$0.date > $1.date})
        })

        alert.addAction(UIAlertAction(title: "취소", style: .default) { _ in
            
        })
        present(alert, animated: true)
    }

    @IBAction func sgChangeListType(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            sectionNum = 1
            sgNum = 0
            sectionName = [""]
            placeTableView.reloadData()
        }else if sender.selectedSegmentIndex == 1{
            sectionNum = groupItem.count
            sgNum = 1
            sectionName.removeAll()
            for group in groupItem{
                sectionName.append(group)
            }
            placeTableView.reloadData()
        }else if sender.selectedSegmentIndex == 2{
            sectionNum = categoryItem.count
            sgNum = 2
            sectionName.removeAll()
            for name in categoryItem{
                sectionName.append(name)
            }
            placeTableView.reloadData()
        }
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
       
        let titleToMove = placeTitles[(fromIndexPath as NSIndexPath).row]
        let imageToMove = placeImages[(fromIndexPath as NSIndexPath).row]
        let subToMove = placeSubTitles[(fromIndexPath as NSIndexPath).row]
        
        
        placeTitles.remove(at: (fromIndexPath as NSIndexPath).row)
        placeImages.remove(at: (fromIndexPath as NSIndexPath).row)
        placeSubTitles.remove(at: (fromIndexPath as NSIndexPath).row)
        
        placeTitles.insert(titleToMove, at: (to as NSIndexPath).row)
        placeImages.insert(imageToMove, at: (to as NSIndexPath).row)
        placeSubTitles.insert(subToMove, at: (to as NSIndexPath).row)
 
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sgPlaceInfo"{
            let cell = sender as! UITableViewCell
            let indexPath = self.placeTableView.indexPath(for: cell)
            let infoView = segue.destination as! PlaceInfoTableViewController
            
            var cellData = [PlaceData]()
            
            switch sgNum {
            case 0:
                cellData = places
            case 1:
                cellData = places.filter({$0.group == sectionName[indexPath!.section]})
            case 2:
                cellData = places.filter({$0.category == sectionName[indexPath!.section]})
            default:
                cellData = places
            }
            
    
       //     infoView.getPlaceInfo(cellData[(indexPath! as NSIndexPath).row], image: cellData[(indexPath! as NSIndexPath).row].orgImg!)
            
            infoView.getPlaceInfo(cellData[(indexPath! as NSIndexPath).row], image: placeImages[cellData[(indexPath! as NSIndexPath).row].name]!)
        
        }
        if segue.identifier == "sgAddPlace"{
            let addView = segue.destination as! AddPlaceTableViewController
            addView.nowPlaceData = places
        }
    }
    
}
