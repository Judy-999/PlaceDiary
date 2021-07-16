//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06.
//


import UIKit
import Firebase

class PlaceInfoTableViewController: UITableViewController, EditDelegate {

    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    var receiveImage: UIImage?
    var reName = ""
    var rePositon = ""
    var reDate = ""
    var reCategory = ""
    var reVisit = false
    var reRate = ""
    var reComent = ""
    var rateBtn = [UIButton]()
    let fillRate = AddRate()
    var rateF : Float?
    var editData : PlaceData?
    var count = "0"
    var reGroup = ""
    
    @IBOutlet var placeImg: UIImageView!
    @IBOutlet var lblPlacename: UILabel!
    @IBOutlet var lblPosition: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblCategory: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var txvComent: UITextView!
    @IBOutlet var btnRate1: UIButton!
    @IBOutlet var btnRate2: UIButton!
    @IBOutlet var btnRate3: UIButton!
    @IBOutlet var btnRate4: UIButton!
    @IBOutlet var btnRate5: UIButton!
    @IBOutlet weak var lblCount: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
     
        rateBtn.append(btnRate1)
        rateBtn.append(btnRate2)
        rateBtn.append(btnRate3)
        rateBtn.append(btnRate4)
        rateBtn.append(btnRate5)
        
        setPlaceInfo()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        placeImg.isUserInteractionEnabled = true
        placeImg.addGestureRecognizer(tap)
        
    }
    
    func getPlaceInfo(_ data: PlaceData, image: UIImage){
        editData = data
        
        reName = data.name
        rePositon = data.location
        receiveImage = image
        reCategory = data.category
        reVisit = data.visit
        reRate = data.rate
        reComent = data.coment
        count = data.count
        reGroup = data.group
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        reDate = formatter.string(from: data.date)
    }
    
    func setPlaceInfo(){
        lblPlacename.text = reName
        lblPosition.text = rePositon
        placeImg.image = receiveImage
        lblDate.text = reDate
        lblCategory.text = reCategory
        txvComent.text = reComent
        lblRate.text = reRate + " 점"
        lblCount.text = count + "회"
        lblGroup.text = reGroup
        fillRate.fill(buttons: rateBtn, rate: NSString(string: reRate).floatValue)
    }

    func didEditPlace(_ controller: AddPlaceTableViewController, data: PlaceData, image: UIImage) {
         getPlaceInfo(data, image: image)
         setPlaceInfo()
    }
    
    @IBAction func clickRate(_ sender: UIButton){
        lblRate.text = String(describing: fillRate.checkAttr(buttons: rateBtn, button: sender))
    }
    
    @IBAction func editBtn(_ sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "장소 편집", style: .default) { _ in
            self.performSegue(withIdentifier: "editPlace", sender: self)
        })

        alert.addAction(UIAlertAction(title: "장소 삭제", style: .default) { _ in
            let alert = UIAlertController(title: "장소 삭제 확인", message: "장소를 삭제하시겠습니까?", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default){ [self] _ in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData?.name)
                _ = navigationController?.popViewController(animated: true)
            }
            let actionCancle = UIAlertAction(title: "취소", style: .default, handler: nil)
            alert.addAction(action)
            alert.addAction(actionCancle)
            self.present(alert, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .default) { _ in
            
        })

        present(alert, animated: true)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "sgShowImage", sender: self)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace"{
            let addPlaceViewController = segue.destination as! AddPlaceTableViewController
            addPlaceViewController.setPlaceDataFromInfo(data: editData!, image: receiveImage!)
            addPlaceViewController.editDelegate = self
        }
        if segue.identifier == "sgShowImage"{
            let imageView = segue.destination as! ImageViewController
            imageView.fullImage = placeImg.image
        }
    }
}
