//
//  CategoryEditController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit

final class EditClassificationController: UITableViewController {
    var editType: EditType = .category
    var places = [Place]()
    private var editItems = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
    
    private func loadCategory() {
        FirestoreManager.shared.loadClassification { [self] categoryItems, groupItems in
            switch editType {
            case .category:
                editItems = categoryItems
            case .group:
                editItems = groupItems
            }
        }
    }
    
    private func updateClassification() {
        FirestoreManager.shared.updateClassification(editType.rawValue,
                                                     with: editItems)
    }
    
    private func modifyCategory(_ oldItem: String, to newItem: String) {
        switch editType {
        case .category:
            places = places.map {
                if $0.category == oldItem {
                    var newPlace = $0
                    newPlace.category = newItem
                    return newPlace
                }
                return $0
            }
            
            places.filter { $0.category == newItem }.forEach {
                FirestoreManager.shared.savePlace($0)
            }
        case .group:
            places = places.map {
                if $0.group == oldItem {
                    var newPlace = $0
                    newPlace.group = newItem
                    return newPlace
                }
                return $0
            }
            
            places.filter { $0.group == newItem }.forEach {
                FirestoreManager.shared.savePlace($0)
                
            }
        }
    }
    
    private func checkNotUsed(item: String) -> Bool {
        switch editType {
        case .category:
            return places.filter { $0.category == item }.isEmpty
        case .group:
            return places.filter { $0.group == item }.isEmpty
        }
    }
    
    @IBAction func addClassificationButtonTapped(_ sender: UIButton){
        let addAlert = UIAlertController(title: "\(editType.title) 추가",
                                         message: nil,
                                         preferredStyle: .alert)
        addAlert.addTextField()
        
        let creation = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let newItem = addAlert.textFields?.first?.text else {
                self?.showAlert(.creationFailedWithEmptyName)
                return
            }
            
            if self?.editItems.contains(newItem) == false {
                self?.editItems.append(newItem)
                self?.updateClassification()
            } else {
                self?.showAlert(.creationFailedWithDuplicate)
            }
        }
        
        addAlert.addAction(Alert.cancel)
        addAlert.addAction(creation)
        present(addAlert, animated: true)
    }
}

// MARK: - TableViewDelegate
extension EditClassificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let editAlert = UIAlertController(title: "\(editType.title) 편집",
                                          message: nil,
                                          preferredStyle: .alert)
        editAlert.addTextField()
        editAlert.textFields?.first?.text = editItems[indexPath.row]
       
        let save = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let newItem = editAlert.textFields?.first?.text else {
                self?.showAlert(.saveFailedWithEmptyName)
                return
            }
            
            if self?.editItems.contains(newItem) == false {
                let old = self?.editItems[indexPath.row] ?? ""
                if let index = self?.editItems.firstIndex(of: old) {
                    self?.editItems[index] = newItem
                }
                self?.modifyCategory(old, to: newItem)
                self?.updateClassification()
            } else {
                self?.showAlert(.saveFailedWithDuplicatedName)
            }
        }
    
        editAlert.addAction(save)
        editAlert.addAction(Alert.cancel)
      
        let editConfirmAlert = UIAlertController(title: nil,
                                                 message: nil,
                                                 preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "편집", style: .default) { [weak self]_ in
            self?.present(editAlert, animated: true)
        }
        
        editConfirmAlert.addAction(edit)
        editConfirmAlert.addAction(Alert.cancel)
        present(editConfirmAlert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = editItems[indexPath.row]
            if checkNotUsed(item: itemToDelete) {
                let canDeleteAlert = UIAlertController(title: "삭제 확인",
                                                       message: itemToDelete + "을(를) 삭제하시겠습니까?",
                                                       preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    if let index = self?.editItems.firstIndex(of: itemToDelete) {
                        self?.editItems.remove(at: index)
                    }
                    self?.updateClassification()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                canDeleteAlert.addAction(Alert.cancel)
                canDeleteAlert.addAction(confirm)
                present(canDeleteAlert, animated: true)
            } else {
                showAlert(.deleteFailed)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension EditClassificationController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return editItems.count
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = editItems[indexPath.row]
        return cell
    }
}

enum EditType: String {
    case category
    case group
    
    var title: String {
        switch self {
        case .category:
            return "분류"
        case .group:
            return "그룹"
        }
    }
}
