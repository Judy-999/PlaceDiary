//
//  GroupInfo.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28.
//

import Foundation
import UIKit

struct GroupInfo {
    var name: String
    var image: UIImage?{
        return UIImage(named: "\(name).jpeg")
    }
    
    
    init (name: String) {
        self.name = name
    }
}
