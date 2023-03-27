//
//  Classification.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/24.
//

struct Classification {
    let category: [String]
    let group: [String]
    
    init(category: [String] = [], group: [String] = []) {
        self.category = category
        self.group = group
    }
}
