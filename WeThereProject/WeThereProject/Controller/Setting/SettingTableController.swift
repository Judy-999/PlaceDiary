//
//  SettingTableController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit

class SettingTableController: UITableViewController {
    private var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getPlaces(_ data: [Place]) {
        places = data
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.category.identifier {
            let setting = segue.destination as! CategoryEditController
            setting.editType = "items"
            setting.typeString = "분류"
            setting.places = places
        }
        
        if segue.identifier == Segue.group.identifier {
            let setting = segue.destination as! CategoryEditController
            setting.editType = "group"
            setting.typeString = "그룹"
            setting.places = places
        }
        
        if segue.identifier == Segue.statistics.identifier {
            let statistics = segue.destination as! StatisticsTableViewController
            statistics.places = places
        }
    }
}

// MARK: - Table view data source
extension SettingTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}
