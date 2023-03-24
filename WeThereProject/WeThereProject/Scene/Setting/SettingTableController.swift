//
//  SettingTableController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit

final class SettingTableController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.category.identifier {
            guard let setting = segue.destination as? EditClassificationController else { return }
            setting.editType = .category
        }
        
        if segue.identifier == Segue.group.identifier {
            guard let setting = segue.destination as? EditClassificationController else { return }
            setting.editType = .group
        }
    }
}

// MARK: TableViewDataSource
extension SettingTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}


