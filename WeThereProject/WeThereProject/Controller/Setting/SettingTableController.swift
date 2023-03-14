//
//  SettingTableController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit

class SettingTableController: UITableViewController {
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func getPlaces(_ data: [Place]){
        places = data
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgCategory"{
            let setting = segue.destination as! CategoryEditController
            setting.editType = "items"
            setting.typeString = "분류"
            setting.places = places
        }
        if segue.identifier == "sgGroup"{
            let setting = segue.destination as! CategoryEditController
            setting.editType = "group"
            setting.typeString = "그룹"
            setting.places = places
        }
        
        if segue.identifier == "sgStatistics"{
            let statistics = segue.destination as! StatisticsTableViewController
            statistics.places = places
        }
    }
}
