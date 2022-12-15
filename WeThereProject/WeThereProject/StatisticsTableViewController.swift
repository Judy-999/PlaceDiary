//
//  StatisticsTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/09/12.
//

import UIKit
import FirebaseFirestore

class StatisticsTableViewController: UITableViewController {

    let sectionName = ["분류", "그룹"]
    var places = [PlaceData]()
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
    
    let db: Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadCategory()

    }
    
    func loadCategory(){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.categoryList = (document.get("items") as? [String])!
                self.groupList = (document.get("group") as? [String])!
            } else {
                print("Document does not exist")
            }
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
        // #warning Incomplete implementation, return the number of rows
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
