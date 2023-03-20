//
//  StatisticsTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/09/12. --> Refacted on 2022/12/15
//

import UIKit

final class StatisticsTableViewController: UITableViewController {
    private var places = [Place]()
    private var categoryList = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var groupList = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlaces()
        loadClassification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaces()
        loadClassification()
    }
    
    private func setupPlaces() {
        places = PlaceDataManager.shared.getPlaces()
    }
    
    private func loadClassification() {
        let calssification: (categoryItems: [String], groupItems: [String])
        = PlaceDataManager.shared.getClassification()
        groupList = calssification.groupItems
        categoryList = calssification.categoryItems
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categoryList.count
        }
        return groupList.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "분류"
        }
        return "그룹"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell", for: indexPath)
        
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
      
        let title: String
        let count: Int
        
        if indexPath.section == 0 {
            title = categoryList[indexPath.row]
            count = places.filter { $0.category == title }.count
        } else {
            title = groupList[indexPath.row]
            count = places.filter { $0.group == title }.count
        }
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(count) 곳"
        
        return cell
    }
}
