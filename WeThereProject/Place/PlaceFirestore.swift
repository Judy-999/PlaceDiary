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
   /*     for document in documents {
            places.append(PlaceData(dictionary: [name : document["name"]],
                                    dictionary: [position : document["position"]])
                                   // position: document["position"] as? String ?? ""))
        }
        */
        for document in documents {
            places.append(PlaceData(name: document["name"] as? String ?? "",
                                    position: document["position"] as? String ?? ""))
                }
        
        return places
    }
}
