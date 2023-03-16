//
//  PlaceInfo.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/13.
//

import UIKit

enum PlaceInfo {
    static let locationPlaceHoler = "이름 또는 주소로 위치를 검색하세요."
    static let comentPlaceHoler = "코멘트를 입력하세요."
    
    enum Main {
        static let empty = "장소를 추가해보세요!"
        static let delete = "장소 삭제"
        static let confirmDelete = "(을)를 삭제하시겠습니까?"
    }
    
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
    
    enum Map {
        static let makerSize = CGSize(width: 30, height: 40)
        static let allType = "전체"
    }
    
    enum Edit {
        static let unfavorite = "즐겨찾기 해제"
        static let addFavorite = "즐겨찾기 추가"
        static let changeFavorit = "즐겨찾기가 변경되었습니다."
        static let editPlace = "장소 편집"
        static let deletePlace = "장소 삭제"
        static let cancel = "취소"
    }
}

enum DiaryImage {
    static let placeholer = UIImage(named: "pdicon")
    
    enum Favorit {
        static let isFavorit = UIImage(systemName: "heart.fill")
        static let isNotFavorit = UIImage(systemName: "heart")
    }
    
    enum Marker {
        static let select = UIImage(named: "marker_select")
        static let favorit = UIImage(named: "marker_basic")
        static let notFavorit = UIImage(named: "marker_novisit")
    }
}

enum Color {
    static let highlight = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
    static let partialHighlight = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    static let placeHolder = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
}
