//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let database = Firestore.firestore()
    
    private init() {}
    
    func loadData(collectionID: String, handler: @escaping ([Place]) -> Void) {
        database.collection(collectionID).order(by: "date", descending: true).addSnapshotListener { querySnapshot, err in
            if let error = err {
                print(error)
                return
            }
            
            if let documents = querySnapshot?.documents {
                let places = documents.compactMap{ Place(from: $0) }
                handler(places)
            }
        }
    }
}
