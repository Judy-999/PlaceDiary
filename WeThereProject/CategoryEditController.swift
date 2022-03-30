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
    var editType = "", typeString = ""
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
            if let newItem = addAlert.textFields?[0].text{
                if checkExisted(item: newItem){
                    uploadCategory(editType, item: newItem, add: true)
                    loadCategory(editType)
                    tableView.reloadData()
                }else{
                    simpleAlert(title: "생성 불가", message: "이미 존재하는 항목입니다.")
                }
            }else{
                simpleAlert(title: "생성 불가", message: "생성할 이름을 입력해주세요")
            }
        }
        addAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        addAlert.addAction(alertOk)
        self.present(addAlert, animated: true, completion: nil)
    }
    
    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func updateField(_ type: String, items: [String]){
        let categoryRef = db.collection("category").document(Uid)

        categoryRef.updateData([
                type : items
        ])
    }

    func modifyCategory(oldItem: String, newItem: String){
        
        if editType == "group"{
            for place in places{
                if place.group == oldItem{
                    db.collection(Uid).document(place.name).updateData([
                        "group" : newItem
                    ])
                }
            }
        }else{
            for place in places{
                if place.category == oldItem{
                    db.collection(Uid).document(place.name).updateData([
                        "category" : newItem
                    ])
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editConfirmAlert = UIAlertController(title: "편집하기", message: "편집하시겠습니까?", preferredStyle: .actionSheet)
        editConfirmAlert.addAction(UIAlertAction(title: "편집", style: .default, handler: { _ in
            let editAlert = UIAlertController(title: "편집하기", message: "새로운 " + self.typeString + "(을)를 입력하세요.", preferredStyle: .alert)
            editAlert.addTextField()
            editAlert.textFields?[0].text = self.editItems[indexPath.row]
            let alertOk = UIAlertAction(title: "저장", style: .default) { [self] _ in
                if let newItem = editAlert.textFields?[0].text{
                    if checkExisted(item: newItem){
                        let old = editItems[indexPath.row]
                        if let index = editItems.firstIndex(of: editItems[indexPath.row]) {
                            editItems[index] = newItem
                        }
                        modifyCategory(oldItem: old, newItem: newItem)
                        updateField(editType, items: editItems)
                        loadCategory(editType)
                        tableView.reloadData()
                    }else{
                        simpleAlert(title: "저장 불가", message: "이미 존재하는 항목입니다.")
                    }
                }else{
                    simpleAlert(title: "저장 불가", message: "항목의 이름을 입력해주세요")
                }
            }
            editAlert.addAction(alertOk)
            editAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
            self.present(editAlert, animated: true, completion: nil)
        }))
        editConfirmAlert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: nil))
        self.present(editConfirmAlert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
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
                canDeleteAlert.addAction(UIAlertAction(title: "취소", style: .default))
                canDeleteAlert.addAction(alertOk)
                self.present(canDeleteAlert, animated: true, completion: nil)
                
            }else{
                simpleAlert(title: "삭제 불가", message: "사용 중인 항목은 삭제할 수 없습니다.")
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
