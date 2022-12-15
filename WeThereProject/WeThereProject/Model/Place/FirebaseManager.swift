//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import Foundation
import FirebaseFirestore

class FirebaseManager {
    let database = Firestore.firestore()

    func get(collectionID: String, handler: @escaping ([Place]) -> Void) {
        database.collection(collectionID).order(by: "date", descending: true).addSnapshotListener { querySnapshot, err in
            if let error = err {
                print(error)
                handler([])
            } else {
                handler(Place.build(from: querySnapshot?.documents ?? []))
            }
        }
    }
}
