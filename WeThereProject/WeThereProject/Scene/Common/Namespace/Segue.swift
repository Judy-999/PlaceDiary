//
//  Segue.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/16.
//

enum Segue {
    case edit
    case detailImage
    case map
    case mapInfo
    case serach
    case calendar
    case category
    case group
    case statistics
    case add
    case info
    
    var identifier: String {
        switch self {
        case .edit:
            return "editPlace"
        case .detailImage:
            return "sgShowImage"
        case .map:
            return "showMap"
        case .mapInfo:
            return "sgMapInfo"
        case .serach:
            return "sgSearchInfo"
        case .calendar:
            return "sgCalendarInfo"
        case .category:
            return "sgCategory"
        case .group:
            return "sgGroup"
        case .statistics:
            return "sgStatistics"
        case .add:
            return "sgAddPlace"
        case .info:
            return "sgPlaceInfo"
        }
    }
}
