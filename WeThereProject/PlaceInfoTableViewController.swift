//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06.
//


import UIKit

class PlaceInfoTableViewController: UITableViewController {

    var receiveImage: UIImage?
    var reName = ""
    var rePositon = ""
    var reDate = ""
    var reCategory = ""
    var reVisit = false
    var reRate = ""
    var rateBtn = [UIButton]()
    
    @IBOutlet var placeImg: UIImageView!
    @IBOutlet var txtPlacename: UITextField!
    @IBOutlet var txtPosition: UITextField!
    @IBOutlet var txtDate: UITextField!
    @IBOutlet var txtCategory: UITextField!
    @IBOutlet var swVisit: UISwitch!
    @IBOutlet var txtRate: UITextField!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var btnRate1: UIButton!
    @IBOutlet var btnRate2: UIButton!
    @IBOutlet var btnRate3: UIButton!
    @IBOutlet var btnRate4: UIButton!
    @IBOutlet var btnRate5: UIButton!
    
    let fillRate = AddRate()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        var rateF = NSString(string: reRate).floatValue
        rateBtn.append(btnRate1)
        rateBtn.append(btnRate2)
        rateBtn.append(btnRate3)
        rateBtn.append(btnRate4)
        rateBtn.append(btnRate5)
        
        txtPlacename.text = reName
        txtPosition.text = rePositon
        placeImg.image = receiveImage
        txtDate.text = reDate
        txtCategory.text = reCategory
        swVisit.isOn = reVisit
        txtRate.text = reRate + " 점"
        
        fillRate.fill(buttons: rateBtn, rate: rateF)
    }
    
    func getInfo(_ data: PlaceData, image: UIImage){
        reName = data.name!
        rePositon = data.position!
        receiveImage = image
        reCategory = data.category!
        reVisit = data.visit!
        reRate = data.rate!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        reDate = formatter.string(from: data.date!)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
