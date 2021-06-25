//
//  PlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

var placeImages = [String : UIImage]()
var isUpdate = true

class PlaceTableViewController: UITableViewController {
    var newImage = true
    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem    //목록 수정버튼 사용
        
        tableView.refreshControl = UIRefreshControl()    //새로고침
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
       
        loadPlaceData()
    }


    func loadPlaceData() {
        service = PlaceService()
        service?.get(collectionID: "users") { places in
            self.allPlaces = places
        }
    }
    
    
    func godata(){
        if isUpdate{
            let vc = self.tabBarController!.viewControllers![1] as! MapViewController
            let nav = self.tabBarController?.viewControllers![3] as! UINavigationController
            let sc = nav.topViewController as! SearchTableViewController
          //  let sc = self.tabBarController!.viewControllers![3] as! SearchTableViewController
            
            vc.getPlace(places)
            sc.setData(places)
            isUpdate = false
        }
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
        }//.resume()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()  //목록 재로딩
    }
    
   
    
    override func viewDidDisappear(_ animated: Bool) {
       godata()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        
        
        cell.textLabel?.font = UIFont .boldSystemFont(ofSize: 20)
        cell.detailTextLabel?.font = UIFont .systemFont(ofSize: 15)
    //    cell.textLabel?.text = placeTitles[(indexPath as NSIndexPath).row]
    //    cell.imageView?.image = places[indexPath.row].image
    //    cell.imageView?.image = placeImages[(indexPath as NSIndexPath).row]
    
        cell.tag += 1
        let tag = cell.tag
        
        if self.newImage {
            self.getImage(imageName: places[indexPath.row].name!) { photo in
                if photo != nil {
                    if cell.tag == tag {
                        DispatchQueue.main.async {
                            placeImages.updateValue(photo!, forKey: self.places[indexPath.row].name!)
                            cell.imageView?.image = photo
                        }
                    //        print(cell.tag)
                    }
                }
                self.newImage = false
            }
        }else{
            cell.imageView?.image = placeImages[places[indexPath.row].name!]
        }
        
        cell.textLabel?.text = places[indexPath.row].name
    //    cell.textLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        cell.detailTextLabel?.text = places[indexPath.row].position
        
        
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
            
            let removePlace = places[(indexPath as NSIndexPath).row].name! as String
            
            
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
            
            
            placeImages.removeValue(forKey: places[(indexPath as NSIndexPath).row].name!)
            places.remove(at: (indexPath as NSIndexPath).row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
            infoView.getInfo(places[(indexPath! as NSIndexPath).row], image: placeImages[places[(indexPath! as NSIndexPath).row].name!]!)
        }
    }
    

}
