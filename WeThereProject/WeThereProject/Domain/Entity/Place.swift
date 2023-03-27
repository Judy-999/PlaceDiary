//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02. --> Refacted on 2022/12/15
//

import Firebase
import Foundation

struct Place {
    let name: String
    let location: String
    let date: Date
    var isFavorit: Bool
    var category : String
    let rating: String
    let coment: String
    let geopoint: GeoPoint
    var group: String
}
