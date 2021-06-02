//
//  PlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import FirebaseFirestore

var placeTitles = [String?]()
var placeImages = [UIImage?]()
var placeSubTitles = ["서브 타이틀"]

var place: Dictionary = [String: Any]()



class PlaceTableViewController: UITableViewController {

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
        
       // dataTypes()
       // getData()
        
        placeTitles.append(place["name"] as? String)
        placeImages.append(UIImage(named: "example.jpeg"))  //예제 플레이스
        placeImages.append(UIImage(named: "example.jpeg"))
        
        loadPlaceData()
    }

    func loadPlaceData() {
            service = PlaceService()
            service?.get(collectionID: "users") { places in
                self.allPlaces = places
            }
        }
    
    private func dataTypes() {  //dictionary로 필드 한꺼번에 저장
        // [START data_types]
        let docData: [String: Any] = [
            "name": "콤마",
            "position": 3.14159265,
            "date": Timestamp(date: Date()),
            "visit": true,
            "tag": ["첫방문", "초코빵 맛집", "자몽주스노맛"]
        ]
        db.collection("users").document("test").setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        // [END data_types]
    }

    private func getData(){
        let docRef = db.collection("users").document("test")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                
              //  self.data = PlaceDate(dictionary: document.data()!) // 필요한 데이터를 저장
                
                place = document.data()! as [String : Any]
                
                let dictionary = document.data()! as [String : Any]
               
                if dictionary["name"] != nil{
                    print(dictionary["name"] as! String)
                    placeTitles.append( dictionary["name"] as? String)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
       
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()  //목록 재로딩
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
  //      cell.textLabel?.text = placeTitles[(indexPath as NSIndexPath).row]
        cell.imageView?.image = placeImages[(indexPath as NSIndexPath).row]
  //      cell.detailTextLabel?.text = placeSubTitles[(indexPath as NSIndexPath).row]
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
            placeTitles.remove(at: (indexPath as NSIndexPath).row)
            placeImages.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
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
            let infoView = segue.destination as! PlaceInfoViewController
            infoView.recievePlace(placeTitles[(indexPath! as NSIndexPath).row]!, subname: placeSubTitles[(indexPath! as NSIndexPath).row], image: placeImages[(indexPath! as NSIndexPath).row]!)
        }
    }
    

}
