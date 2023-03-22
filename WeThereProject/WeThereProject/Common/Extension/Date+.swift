//
//  Date+.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/14.
//

import Foundation

extension Date {
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var toString: String {
        return formatter.string(from: self)
    }
    
    var toRegular: Date {
        let dateString = self.toString
        let regularDate = formatter.date(from: dateString)
        return regularDate ?? self
    }
}
