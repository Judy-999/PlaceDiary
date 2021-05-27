//
//  PlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit

var placeTitles = ["새로운 플레이스"]
var placeImages = [UIImage?]()

class PlaceTableViewController: UITableViewController {

    @IBOutlet var placeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem    //목록 수정버튼 사용
        placeImages.append(UIImage(named: "example.jpeg"))
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
        return placeTitles.count
    }

    // 셀 설정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)

        cell.textLabel?.text = placeTitles[(indexPath as NSIndexPath).row]   //임시
        cell.imageView?.image = placeImages[(indexPath as NSIndexPath).row]  //임시

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
            infoView.recievePlace(placeTitles[(indexPath! as NSIndexPath).row], image: placeImages[(indexPath! as NSIndexPath).row]!)
        }
    }
    

}
