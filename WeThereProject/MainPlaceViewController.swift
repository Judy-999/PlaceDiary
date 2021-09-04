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
    private let loadingView = UIView();
    var newUapdate = true
    var loadingCount = 0
    var sectionNum = 1
    var sgNum = 0
    var sectionName = [""]
    var categoryItem = [String]()
    var groupItem = [String]()
    var placeImages = [String : UIImage]()
    
    let storageRef = Storage.storage().reference()
    
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
       

        placeTableView.refreshControl = UIRefreshControl()    //새로고침
        placeTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        placeTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        loadPlaceData()
        downloadList()
        
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
        let vc = self.tabBarController?.viewControllers![3] as! MapViewController
        let nav = self.tabBarController?.viewControllers![1] as! UINavigationController
        let sc = nav.topViewController as! SearchTableViewController
        let cnav = self.tabBarController?.viewControllers![2] as! UINavigationController
        let cc = cnav.topViewController as! CalendarController
        //  let sc = self.tabBarController!.viewControllers![3] as! SearchTableViewController
        
        cc.getDate(places, images: placeImages)
        vc.getPlace(places, images: placeImages)
        sc.setData(places, images: placeImages)
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
        
        if placeImages[cellData[indexPath.row].name] != nil{
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
                    
            /*getImage(place: places[indexPath.row]) { photo in
                    if photo != nil {
                        DispatchQueue.main.async { [self] in
                            cell.imgPlace.image = photo
                            places[indexPath.row].orgImg = photo
                            placeImages.updateValue(photo!, forKey: self.places[indexPath.row].name)
                         }
                     }
                }*/
        }
        
        cell.lblPlaceName.text = cellData[indexPath.row].name
        cell.lblPlaceLocation.text = cellData[indexPath.row].location
        
        if places[indexPath.row].rate != "0.0"{
            cell.lblPlaceInfo.text = cellData[indexPath.row].rate + "점"
        }else{
            cell.lblPlaceInfo.text = "가보고 싶어요!"
        }
        
        return cell
    }
        
    func getImage(place: PlaceData, completion: @escaping (UIImage?) -> ()) {
        let fileName = place.name + "_original"
        let islandRef = storage.reference().child(fileName)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            let downloadImg = UIImage(data: data! as Data)
            if error == nil {
                completion(downloadImg)
                print("image download!!!" + fileName)
            } else {
                    completion(nil)
            }
        }
    }
 
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    //셀 삭제
            // Delete the row from the data source
            
            let cellData = getPlaceList(sectionNum: sgNum, index: indexPath)
            let removePlace = cellData[(indexPath as NSIndexPath).row].name as String
            
            
            db.collection("users").document(removePlace).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            storage.reference().child(removePlace).delete { error in
                if let error = error {
                    print("Error removing image: \(error)")
                } else {
                    print("Image successfully removed!")
                }
              }
            
            storage.reference().child(removePlace + "_original").delete { error in
                if let error = error {
                    print("Error removing image: \(error)")
                } else {
                    print("Image successfully removed!")
                }
              }
            
      //      placeImages.removeValue(forKey: cellData[(indexPath as NSIndexPath).row].name)
      
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
