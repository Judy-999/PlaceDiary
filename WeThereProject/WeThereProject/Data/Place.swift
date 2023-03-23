//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02. --> Refacted on 2022/12/15
//

import Firebase
import UIKit

struct Place {
    var name: String
    var location: String
    var date: Date
    var isFavorit: Bool
    var category : String
    var rating: String
    var coment: String
    var geopoint: GeoPoint
    var group: String
}
