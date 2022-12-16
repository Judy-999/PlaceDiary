//
//  CategoryEditController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit
import FirebaseFirestore

class CategoryEditController: UITableViewController, UIColorPickerViewControllerDelegate {
    var editType = "", typeString = ""
    var places = [Place]()
    var editItems = [String](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory(editType)
    }
        
    func loadCategory(_ type: String) {
        FirestoreManager.shared.loadClassification { categoryItems, groupItems in
            if type == "group" {
                self.editItems = groupItems
            } else {
                self.editItems = categoryItems
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
                    editItems.append(newItem)
                    updateField(editType, items: editItems)
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

    func updateField(_ type: String, items: [String]) {
        FirestoreManager.shared.updateClassification(type, with: items)
    }

    func modifyCategory(oldItem: String, newItem: String) {
        if editType == "group" {
            places = places.map {
                if $0.group == oldItem {
                    var newPlace = $0
                    newPlace.group = newItem
                    return newPlace
                }
                return $0
            }
        } else {
            places = places.map {
                if $0.category == oldItem {
                    var newPlace = $0
                    newPlace.category = newItem
                    return newPlace
                }
                return $0
            }
        }
        
        places.forEach {
            FirestoreManager.shared.savePlace($0)
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removeItem = editItems[(indexPath as NSIndexPath).row] as String
            if checkUsedItem(item: removeItem){
                let canDeleteAlert = UIAlertController(title: "삭제 확인", message: removeItem + "을(를) 삭제하시겠습니까?", preferredStyle: .alert)
                let alertOk = UIAlertAction(title: "확인", style: .default) { (alertOk) in
                    if let index = self.editItems.firstIndex(of: removeItem) {
                        self.editItems.remove(at: index)
                    }
                    
                    self.updateField(self.editType, items: self.editItems)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                canDeleteAlert.addAction(UIAlertAction(title: "취소", style: .default))
                canDeleteAlert.addAction(alertOk)
                self.present(canDeleteAlert, animated: true, completion: nil)
                
            }else{
                simpleAlert(title: "삭제 불가", message: "사용 중인 항목은 삭제할 수 없습니다.")
            }
    
        } else if editingStyle == .insert {
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
}
