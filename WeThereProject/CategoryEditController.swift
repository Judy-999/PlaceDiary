//
//  CategoryEditController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20.
//

import UIKit
import FirebaseFirestore

class CategoryEditController: UITableViewController, UIColorPickerViewControllerDelegate {

    let db: Firestore = Firestore.firestore()
    var editType = ""
    var typeString = ""
    var places = [PlaceData]()
    var editItems = [String](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadCategory(editType)
    }
    
    func loadCategory(_ type: String){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.editItems = (document.get(type) as? [String])!
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)

        cell.textLabel?.text = self.editItems[(indexPath as NSIndexPath).row]

        return cell
    }
    
    @IBAction func addCategory(_ sender: UIButton){
        let addAlert = UIAlertController(title: typeString + " 추가", message: "새로운 " + typeString + "(을)를 입력하세요.", preferredStyle: .alert)
        addAlert.addTextField()
        let alertOk = UIAlertAction(title: "추가", style: .default) { [self] (alertOk) in
            if addAlert.textFields?[0].text != nil{
                if self.checkExisted(item: (addAlert.textFields?[0].text)!){
                    self.uploadCategory(self.editType, item: (addAlert.textFields?[0].text)!, add: true)
                    self.loadCategory(self.editType)
                    self.tableView.reloadData()
                }else{
                    let cantInsertAlert = UIAlertController(title: "생성 불가", message: "이미 존재하는 항목입니다.", preferredStyle: .alert)
                    let alertOk = UIAlertAction(title: "확인", style: .default) { (alertOk) in
                    }
                    cantInsertAlert.addAction(alertOk)
                    self.present(cantInsertAlert, animated: true, completion: nil)
                }
            }
        }
        let alertCancle = UIAlertAction(title: "취소", style: .default) { (alertCancel) in}
        addAlert.addAction(alertCancle)
        addAlert.addAction(alertOk)
        self.present(addAlert, animated: true, completion: nil)
    }
    
    func uploadCategory(_ type: String, item: String, add: Bool){
        
        let categoryRef = db.collection("category").document(Uid)
        
        if add{
            categoryRef.updateData([
                type : FieldValue.arrayUnion([item])
                ])
        }else{
            categoryRef.updateData([
                type : FieldValue.arrayRemove([item])
            ])
        }
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
        if editingStyle == .delete {
            // Delete the row from the data source
            let removeItem = editItems[(indexPath as NSIndexPath).row] as String
            if checkUsedItem(item: removeItem){
                let canDeleteAlert = UIAlertController(title: "삭제 확인", message: removeItem + "을(를) 삭제하시겠습니까?", preferredStyle: .alert)
                let alertOk = UIAlertAction(title: "확인", style: .default) { (alertOk) in
                    self.uploadCategory(self.editType, item: removeItem, add: false)
                    if let index = self.editItems.firstIndex(of: removeItem) {
                        self.editItems.remove(at: index)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                let alertNo = UIAlertAction(title: "취소", style: .default) { (alertNo) in
                }
               
                canDeleteAlert.addAction(alertOk)
                canDeleteAlert.addAction(alertNo)
                
                self.present(canDeleteAlert, animated: true, completion: nil)
                
            }else{
                let cantDeleteAlert = UIAlertController(title: "삭제 불가", message: "사용 중인 항목은 삭제할 수 없습니다.", preferredStyle: .alert)
                let alertOk = UIAlertAction(title: "확인", style: .default) { (alertOk) in
                }
                cantDeleteAlert.addAction(alertOk)
                self.present(cantDeleteAlert, animated: true, completion: nil)
            }
    
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    func checkUsedItem(item: String) -> Bool{
        if editType == "items"{
            for place in places{
                if place.category == item{
                    return false
                }
            }
        }else{
            for place in places{
                if place.group == item{
                    return false
                }
            }
        }
        return true
    }
    
    func checkExisted(item: String) -> Bool{
        for name in editItems{
            if name == item{
                return false
            }
        }
        return true
    }
    
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
/*
extension CategoryEditController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        print(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    //
    }
}
*/
