//
//  PlaceFirestore.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import Foundation
import FirebaseFirestore

extension PlaceData {
    static func build(from documents: [QueryDocumentSnapshot]) -> [PlaceData] {
        var places = [PlaceData]()
    
        for document in documents {
            let date = document["date"] as! Timestamp
            
            places.append(PlaceData(name: document["name"] as? String ?? "",
                                    location: document["position"] as? String ?? "",
                                    date: date.dateValue(),
                                    visit: (document["visit"] as? Bool)!,
                                    image: (document["image"] as? Bool)!,
                                    count: document["count"] as? String ?? "",
                                    category: document["category"] as? String ?? "",
                                    rate: document["rate"] as? String ?? "",
                                    coment: document["coment"] as? String ?? "",
                                    geopoint: (document["geopoint"] as? GeoPoint)!,
                                    group: document["group"] as? String ?? ""))
        }
        return places
    }
}
