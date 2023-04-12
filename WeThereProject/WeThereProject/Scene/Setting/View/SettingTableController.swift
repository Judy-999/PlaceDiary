//
//  SettingTableController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/20. --> Refacted on 2022/12/15
//

import UIKit

final class SettingTableController: UITableViewController {
    private let viewModel: SettingViewModel

    required init?(viewModel: SettingViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            viewModel.showEditClassification(type: .category)
        case 1:
            viewModel.showEditClassification(type: .group)
        case 2:
            viewModel.showStatistics()
        default :
            break
        }
    }
}

enum ClassificationType: Int {
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
    
    var description: String {
        switch self {
        case .category:
            return "category"
        case .group:
            return "group"
        }
    }
}
