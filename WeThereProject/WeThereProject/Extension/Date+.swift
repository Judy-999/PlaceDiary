//
//  Date+.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/14.
//

import Foundation

extension Date {
    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
