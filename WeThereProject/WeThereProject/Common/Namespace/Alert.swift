//
//  Alert.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/16.
//

import UIKit

enum Alert {
    static let cancel = UIAlertAction(title: "취소", style: .cancel)
    
    case duplicatePlace
    case insufficientInput
    case deleteFailed
    case saveFailedWithEmptyName
    case saveFailedWithDuplicatedName
    case creationFailedWithDuplicate
    case creationFailedWithEmptyName
    
    var title: String {
        switch self {
        case .duplicatePlace:
            return "중복된 장소 이름"
        case .insufficientInput:
            return "필수 입력 미기재"
        case .deleteFailed:
            return "삭제 불가"
        case .saveFailedWithEmptyName, .saveFailedWithDuplicatedName:
            return "저장 불가"
        case .creationFailedWithDuplicate, .creationFailedWithEmptyName:
            return "생성 불가"
        }
    }
    
    var message: String {
        switch self {
        case .duplicatePlace:
            return "같은 이름의 장소가 존재합니다."
        case .insufficientInput:
            return "모든 항목을 입력해주세요."
        case .deleteFailed:
            return "사용 중인 항목은 삭제할 수 없습니다."
        case .saveFailedWithEmptyName:
            return "항목의 이름을 입력해주세요"
        case .saveFailedWithDuplicatedName:
            return "이미 존재하는 항목입니다."
        case .creationFailedWithDuplicate:
            return "이미 존재하는 항목입니다."
        case .creationFailedWithEmptyName:
            return "생성할 이름을 입력해주세요"
        }
    }
}
