//
//  Bundle+.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/22.
//

import Foundation

extension Bundle {
    var gmsApiKey: String {
        guard let file = self.path(forResource: "GMSInfo", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["GMS_API_KEY"] as? String else { fatalError("GMS_API_KEY에 값을 가져올 수 없습니다.")}
        return key
    }
}
