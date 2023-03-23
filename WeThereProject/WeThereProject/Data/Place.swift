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

extension Place {
    init?(from document: QueryDocumentSnapshot) {
        guard let name = document["name"] as? String,
              let location = document["position"] as? String,
              let date = document["date"] as? Timestamp,
              let isFavorit = document["favorit"] as? Bool,
              let category = document["category"] as? String,
              let rate = document["rate"] as? String,
              let coment = document["coment"] as? String,
              let geopoint = document["geopoint"] as? GeoPoint,
              let group = document["group"] as? String else { return nil }
        
        self.name = name
        self.location = location
        self.date = date.dateValue()
        self.isFavorit = isFavorit
        self.category = category
        self.rating = rate
        self.coment = coment
        self.geopoint = geopoint
        self.group = group
    }
}
