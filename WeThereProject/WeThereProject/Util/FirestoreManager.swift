//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import FirebaseFirestore
import UIKit

class FirestoreManager {
    static let shared = FirestoreManager()
    private let database = Firestore.firestore()
    private let id: String
    
    private init() {
        guard let collectionID = UIDevice.current.identifierForVendor?.uuidString else {
            id = ""
            return
        }
        
        id = collectionID
    }
    
    func loadData(completionHandler: @escaping ([Place]) -> Void) {
        database.collection(id).order(by: "date", descending: true).addSnapshotListener { querySnapshot, err in
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
        database.collection("category").document(id).getDocument { document, error in
            if let document = document, document.exists {
                guard let categoryItems = document.get("items") as? [String],
                      let groupItems = document.get("group") as? [String] else { return }
                
                completionHandler(categoryItems, groupItems)
            } else {
                self.setupBasicClassification(completionHandler)
            }
        }
    }
    
    func updateClassification(_ classification: String, with items: [String]){
        database.collection("category").document(id).updateData([
            classification : items
        ])
    }
    
    func deletePlace(_ name: String) {
        database.collection(id).document(name).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func savePlace(_ place: Place) {
        let saveData: [String: Any] = [
           "name": place.name,
           "position": place.location,
           "date": place.date,
           "favorit": place.isFavorit,
           "rate": place.rate,
           "coment": place.coment,
           "category": place.category,
           "geopoint": place.geopoint,
           "image": place.hasImage,
           "group": place.group
       ]

       database.collection(id).document(place.name).setData(saveData) { err in
           if let err = err {
               print("Error writing document: \(err)")
           } else {
               print("Document successfully written!")
           }
       }
    }
    
    func updateFavorit(_ favorit: Bool, placeName: String) {
        database.collection(id).document(placeName).updateData([ "favorit": favorit ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    private func setupBasicClassification(_ completionHandler: @escaping (_ categoryItems: [String], _ groupItems: [String]) -> Void) {
        database.collection("category").document(id).setData(Classification.basic) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                self.loadClassification(completionHandler: completionHandler)
            }
        }
    }
}

enum Classification {
    static let basic: [String: [String]] = ["items": ["카페", "음식점", "디저트", "전시회", "액티비티", "야외"],
                                            "group": ["친구", "가족", "애인", "혼자"]]
}
