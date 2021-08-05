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

var placeImages = [String : UIImage]()

class MainPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ImageDelegate {
   
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
  
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
       // self.navigationItem.leftBarButtonItem = self.editButtonItem    //목록 수정버튼 사용
        
        loadingView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        loadingView.backgroundColor = UIColor.white
        self.view.addSubview(loadingView)
        let indicator = NVActivityIndicatorView(frame: CGRect(x: width/2 - 25, y: height/2 - 100, width: 50, height: 50),
                                                type: .ballRotateChase,
                                                color: #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1),
                                                padding: 0)
        loadingView.addSubview(indicator)
        indicator.startAnimating()
        
        placeTableView.refreshControl = UIRefreshControl()    //새로고침
        placeTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        placeTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        loadPlaceData()
        downloadList()

        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name(rawValue: "endLoading"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newUpdate), name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
    }
    
    @objc func stopLoading(){
   /*     if loadingCount == 0{
            DispatchQueue.main.async {
                self.getOrgImg()
            }
        }*/
        loadingCount = loadingCount + 1
        print("로딩 카운트 : " + String(loadingCount) + " 전체 카운트 : " + String(places.count))
        if loadingCount == places.count{
            loadingView.removeFromSuperview()
            print("스탐햇오")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "endLoading"), object: nil)
            
        }
    }
    
    func didOrgImageDone(_ controller: PlaceInfoTableViewController, name: String, image: UIImage) {
        let index = places.firstIndex(where: {$0.name == name})!
        places[index].orgImg = image
        print("여기 실행 된비끼")
    }
    
    func getOrgImg(){
        for place in places{
            if place.image == true{
                let imgName = place.name + "_original"
                let fileUrl = "gs://wethere-2935d.appspot.com/" + imgName
                Storage.storage().reference(forURL: fileUrl).downloadURL { url, error in
                    let data = NSData(contentsOf: url!)
                    let downloadImg = UIImage(data: data! as Data)
                    if error == nil {
                        placeImages.updateValue(downloadImg!, forKey: place.name)
                        print("image download!!!" + imgName)
                    }
                }
            }
        }
    }
/*
    func getOrgImg(name : String){
        let imgName = name + "_original"
        let fileUrl = "gs://wethere-2935d.appspot.com/" + imgName
        Storage.storage().reference(forURL: fileUrl).downloadURL { url, error in
            let data = NSData(contentsOf: url!)
            let downloadImg = UIImage(data: data! as Data)
            if error == nil {
                placeImages.updateValue(downloadImg!, forKey: name)
                print("image download!!!" + imgName)
            }
        }
    }
*/
    
    @objc func newUpdate(_ notification: Notification){
        newUapdate = true
        if notification.object != nil{
            let deleteName = notification.object as! String
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
    
    
    func loadPlaceData() {
        service = PlaceService()
        service?.get(collectionID: "users") { places in
            self.allPlaces = places
        }
    }

    
    func downloadList(){
        let docRef = db.collection("category").document("category")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.categoryItem = (document.get("items") as? [String])!
                self.groupItem = (document.get("group") as? [String])!
            } else {
                print("Document does not exist")
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
        
        cc.getDate(places)
        vc.getPlace(places)
        sc.setData(places)
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
        
        var cellData = [PlaceData]()
        
        switch sgNum {
        case 0:
            cellData = places
        case 1:
            cellData =  places.filter({$0.group == sectionName[indexPath.section]})
        case 2:
            cellData = places.filter({$0.category == sectionName[indexPath.section]})
        default:
            cellData = places
        }
        
        if placeImages[cellData[indexPath.row].name] == nil{
            cell.setImage(cellData[indexPath.row])
        }else{
            cell.imgPlace.image = placeImages[cellData[indexPath.row].name]
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

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    //셀 삭제
            // Delete the row from the data source
            var cellData = [PlaceData]()
            
            switch sgNum {
            case 0:
                cellData = places
            case 1:
                cellData =  places.filter({$0.group == sectionName[indexPath.section]})
            case 2:
                cellData = places.filter({$0.category == sectionName[indexPath.section]})
            default:
                cellData = places
            }
            
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
            
            
            placeImages.removeValue(forKey: cellData[(indexPath as NSIndexPath).row].name)
        //    places.remove(at: (indexPath as NSIndexPath).row)
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
            
            infoView.getPlaceInfo(cellData[(indexPath! as NSIndexPath).row], image: placeImages[cellData[(indexPath! as NSIndexPath).row].name]!)
            /*
            if cellData[(indexPath! as NSIndexPath).row].image{
                infoView.getPlaceInfo(cellData[(indexPath! as NSIndexPath).row], image: placeImages[cellData[(indexPath! as NSIndexPath).row].name]!)
            }else{
                infoView.getPlaceInfo(cellData[(indexPath! as NSIndexPath).row], image: UIImage(named: "example.jpeg")!)
            }
 */
        }
        if segue.identifier == "sgAddPlace"{
            let addView = segue.destination as! AddPlaceTableViewController
            addView.nowPlaceData = places
        }
    }
    
}
