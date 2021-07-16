//
//  PlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView

// var placeImages = [String : UIImage]()

class PlaceTableViewController: UITableViewController {
  //  var newImage = true
    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    private let loadingView = UIView();
    var newUapdate = true
    var loadingCount = 0
    
    var places = [PlaceData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        
        tableView.refreshControl = UIRefreshControl()    //새로고침
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        loadPlaceData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name(rawValue: "endLoading"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newUpdate), name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
        

    }

    @objc func stopLoading(){
        loadingCount = loadingCount + 1
        print("로딩 카운트 : " + String(loadingCount) + " 전체 카운트 : " + String(places.count))
        if loadingCount == places.count{
            loadingView.removeFromSuperview()
            print("스탐햇오")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "endLoading"), object: nil)
        }
    }
    
    @objc func newUpdate(_ notification: Notification){
        newUapdate = true
        if notification.object != nil{
            let deleteName = notification.object
            let index = places.firstIndex(where: {$0.name == deleteName as! String})!
            tableView(tableView, commit: .delete, forRowAt: [0, index as Int])
        }
    }
    
    func loadPlaceData() {
        service = PlaceService()
        service?.get(collectionID: "users") { places in
            self.allPlaces = places
        }
    }
    
    
   func godata(){
    print("데이터 보내열!!!")
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
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    
    func getImage(imageName: String, completion: @escaping (UIImage?) -> ()) {
        let fileUrl = "gs://wethere-2935d.appspot.com/" + imageName
        storage.reference(forURL: fileUrl).downloadURL { url, error in
            let data = NSData(contentsOf: url!)
            let downloadImg = UIImage(data: data! as Data)
            if error == nil {
                completion(downloadImg)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print("image download!!!" + imageName)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()  //목록 재로딩
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

    //테이블 안 섹션의 개수
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //섹션당 열 개수(item 개수)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       // return placeTitles.count
        return places.count
    }

    // 셀 설정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        
        
 //       cell.textLabel?.font = UIFont .boldSystemFont(ofSize: 20)
 //       cell.detailTextLabel?.font = UIFont .systemFont(ofSize: 15)
    
       
        /*
        cell.tag += 1
        let tag = cell.tag
        
        
        if self.newImage {
            self.getImage(imageName: places[indexPath.row].name) { photo in
                if photo != nil {
                    if cell.tag == tag {
                        DispatchQueue.main.async {
                            placeImages.updateValue(photo!, forKey: self.places[indexPath.row].name)
                            cell.imgPlace.image = photo
                            // cell.imageView?.image = photo
                        }
                    //        print(cell.tag)
                    }
                }
                self.newImage = false
            }
        }else{
            cell.imgPlace.image = placeImages[places[indexPath.row].name]
        }*/
        if placeImages[places[indexPath.row].name] == nil{
            cell.setImage(places[indexPath.row])
        }else{
            cell.imgPlace.image = placeImages[places[indexPath.row].name]
        }

        
        cell.lblPlaceName.text = places[indexPath.row].name
        cell.lblPlaceLocation.text = places[indexPath.row].location
        
        if places[indexPath.row].rate != "0.0"{
            cell.lblPlaceInfo.text = places[indexPath.row].rate + "점"
        }else{
            cell.lblPlaceInfo.text = "가보고 싶어요!"
        }
        /*
        cell.textLabel?.text = places[indexPath.row].name
    //    cell.textLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        cell.detailTextLabel?.text = places[indexPath.row].location
        */
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    //셀 삭제
            // Delete the row from the data source
            
            let removePlace = places[(indexPath as NSIndexPath).row].name as String
            
            
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
            
            
            placeImages.removeValue(forKey: places[(indexPath as NSIndexPath).row].name)
            places.remove(at: (indexPath as NSIndexPath).row)
            newUapdate = true
            
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            
            if places[(indexPath! as NSIndexPath).row].image{
                infoView.getPlaceInfo(places[(indexPath! as NSIndexPath).row], image: placeImages[places[(indexPath! as NSIndexPath).row].name]!)
            }else{
                infoView.getPlaceInfo(places[(indexPath! as NSIndexPath).row], image: UIImage(named: "example.jpeg")!)
            }
        }
        if segue.identifier == "sgAddPlace"{
            let addView = segue.destination as! AddPlaceTableViewController
            addView.nowPlaceData = places
        }
    }
    

}
