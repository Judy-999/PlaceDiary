//
//  TabBarPage.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import UIKit

enum TabBarPage: CaseIterable {
    case list
    case search
    case calendar
    case map
    case setting
    
    static let selectedColor = Color.highlight
    
    var number: Int {
        switch self {
        case .list:
            return 0
        case .search:
            return 1
        case .calendar:
            return 2
        case .map:
            return 3
        case .setting:
            return 4
        }
    }
    
    var title: String {
        switch self {
        case .list:
            return "홈"
        case .search:
            return "검색"
        case .calendar:
            return "캘린더"
        case .map:
            return "지도"
        case .setting:
            return "설정"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .list:
            return UIImage(systemName: "house")
        case .search:
            return UIImage(systemName: "magnifyingglass")
        case .calendar:
            return UIImage(systemName: "calendar")
        case .map:
            return UIImage(systemName: "map")
        case .setting:
            return UIImage(systemName: "gearshape")
        }
    }
}
