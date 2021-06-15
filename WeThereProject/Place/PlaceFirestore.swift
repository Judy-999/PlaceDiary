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
                                    position: document["position"] as? String ?? "",
                                    date: date.dateValue(),
                                    visit: document["visit"] as? Bool,
                                    category: document["category"] as? String ?? "",
                                    rate: document["rate"] as? String ?? "", coment: document["coment"] as? String ?? ""))
        }
        return places
    }
}
