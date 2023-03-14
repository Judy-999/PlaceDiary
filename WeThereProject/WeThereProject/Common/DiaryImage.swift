//
//  DiaryImage.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/13.
//

import UIKit

enum DiaryImage {
    static let placeholer = UIImage(named: "pdicon")
    
    enum Favorit {
        static let isFavorit = UIImage(systemName: "heart.fill")
        static let isNotFavorit = UIImage(systemName: "heart")
    }
}

enum PlaceInfo {
    static let locationPlaceHoler = "이름 또는 주소로 위치를 검색하세요."
    static let comentPlaceHoler = "코멘트를 입력하세요."
    
    
    enum Calendar {
        static let emptyDate = "장소가 없습니다."
        static let eventCount = 3
        static let headerFormat = "YYYY년 M월"
    }
    
    enum Search {
        static let noSearch = "검색된 장소가 없습니다."
        static let emptySearch = "검색할 장소가 없습니다."
        static let placeHolder = "키워드 검색 ex. 이름, 내용..."
        static let title = "검색"
    }
    
    enum Edit {
        static let unfavorite = "즐겨찾기 해제"
        static let addFavorite = "즐겨찾기 추가"
        static let changeFavorit = "즐겨찾기가 변경되었습니다."
        static let editPlace = "장소 편집"
        static let deletePlace = "장소 삭제"
        static let cancel = "취소"
    }
    
    enum Message {
        case duplicatePlace
        case insufficientInput
        
        var title: String {
            switch self {
            case .duplicatePlace:
                return "중복된 장소 이름"
            case .insufficientInput:
                return "필수 입력 미기재"
            }
        }
        
        var message: String {
            switch self {
            case .duplicatePlace:
                return "같은 이름의 장소가 존재합니다."
            case .insufficientInput:
                return "모든 항목을 입력해주세요."
            }
        }
    }
}

enum Color {
    static let highlight = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
    static let partialHighlight = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    static let placeHolder = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
}

enum Segue {
    case edit
    case detailImage
    case map
    case serach
    case calendar
    
    var identifier: String {
        switch self {
        case .edit:
            return "editPlace"
        case .detailImage:
            return "sgShowImage"
        case .map:
            return "showMap"
        case .serach:
            return "sgSearchInfo"
        case .calendar:
            return "sgCalendarInfo"
        }
    }
}
