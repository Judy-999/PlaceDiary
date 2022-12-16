//
//  StatisticsTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/09/12. --> Refacted on 2022/12/15
//

import UIKit
import FirebaseFirestore

class StatisticsTableViewController: UITableViewController {
    let sectionName = ["분류", "그룹"]
    var places = [Place]()
    var dicCategory = [String : Int]()
    var dicGroup = [String : Int]()
    var categoryList = [String](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var groupList = [String](){
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
    
    func loadCategory(){
        FirestoreManager.shared.loadClassification { categoryItems, groupItems in
            self.categoryList = categoryItems
            self.groupList = groupItems
        }
    }
    
    func calculate(name: String) -> String{
        var count = 0
        for place in places{
            if place.category == name || place.group == name{
                count = count + 1
            }
        }
        return String(count)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return categoryList.count
        }else{
            return groupList.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell", for: indexPath)
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.font = UIFont .systemFont(ofSize: 17)
        
        let index = (indexPath as NSIndexPath).row
        
        if indexPath.section == 0{
            cell.textLabel?.text = categoryList[index]
            cell.detailTextLabel?.text = calculate(name: categoryList[index]) + " 곳"
        }else{
            cell.textLabel?.text = groupList[index]
            cell.detailTextLabel?.text = calculate(name: groupList[index]) + " 곳"
        }

        return cell
    }
}
