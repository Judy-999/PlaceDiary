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
    
    func loadData(collectionID: String, completionHandler: @escaping ([Place]) -> Void) {
        database.collection(collectionID).order(by: "date", descending: true).addSnapshotListener { querySnapshot, err in
            if let error = err {
                print(error)
                return
            }
            
            if let documents = querySnapshot?.documents {
                let places = documents.compactMap{ Place(from: $0) }
                completionHandler(places)
            }
        }
    }
    
    func loadClassification(completionHandler: @escaping (_ categoryItems: [String], _ groupItems: [String]) -> Void) {
        let docRef = database.collection("category").document(Uid)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                guard let categoryItems = document.get("items") as? [String],
                      let groupItems = document.get("group") as? [String] else { return }
                
                completionHandler(categoryItems, groupItems)
            } else {
//                docRef.setData(Classification.basic) { err in
//                    // 기본 분류 저장
//                }
            }
        }
    }
    
    func deletePlace(_ name: String) {
        database.collection(Uid).document(name).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}

enum Classification {
    static let basic: [String: [String]] = ["items": ["카페", "음식점", "디저트", "전시회", "액티비티", "야외"],
                                            "group": ["친구", "가족", "애인", "혼자"]]
}
