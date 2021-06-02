//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import Foundation
import FirebaseFirestore

class PlaceService {
    let database = Firestore.firestore()

    func get(collectionID: String, handler: @escaping ([PlaceData]) -> Void) {
        database.collection("users")
            .addSnapshotListener { querySnapshot, err in
                if let error = err {
                    print(error)
                    handler([])
                } else {
                    handler(PlaceData.build(from: querySnapshot?.documents ?? []))
                }
            }
    }
}
