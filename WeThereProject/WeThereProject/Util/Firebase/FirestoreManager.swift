//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import FirebaseFirestore
import UIKit

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let database = Firestore.firestore()
    private let id: String
    
    private init() {
        id = UIDevice.current.identifierForVendor!.uuidString
    }
    
    func loadData(_ completion: @escaping (Result<[Place], FirebaseError>) -> Void) {
        database.collection(id).order(by: PlaceData.date, descending: true)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    completion(.failure(.fetch))
                    return
                }
                
                if let documents = querySnapshot?.documents {
                    let places = documents.compactMap { Place(from: $0) }
                    completion(.success(places))
                }
            }
    }
    
    func loadClassification(_ completion: @escaping (Result<([String], [String]), FirebaseError>) -> Void) {
        database.collection(Classification.collection).document(id)
            .getDocument { [weak self] document, error in
                if let document = document, document.exists {
                    guard let categories = document.get(PlaceData.category) as? [String],
                          let groups = document.get(PlaceData.group) as? [String] else { return }
                    
                    completion(.success((categories, groups)))
                    return
                }
                
                self?.setupBasicClassification(completion)
            }
    }
    
    func updateClassification(_ classification: String, with items: [String]) {
        database.collection(Classification.collection).document(id).updateData([
            classification : items
        ])
    }
    
    func deletePlace(_ name: String,
                     _ completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        database.collection(id).document(name).delete() { error in
            if error != nil {
                completion(.failure(.delete))
                return
            }
            
            completion(.success(()))
        }
    }
    
    func savePlace(_ place: Place,
                   _ completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        let saveData: [String: Any] = [
            PlaceData.name: place.name,
            PlaceData.location: place.location,
            PlaceData.date: place.date,
            PlaceData.favorit: place.isFavorit,
            PlaceData.rating: place.rating,
            PlaceData.coment: place.coment,
            PlaceData.category: place.category,
            PlaceData.geopoint: place.geopoint,
            PlaceData.group: place.group
        ]
        
        database.collection(id).document(place.name)
            .setData(saveData) { error in
                if error != nil {
                    completion(.failure(.save))
                    return
                }
                
                completion(.success(()))
            }
    }
    
    func updateFavorit(_ favorit: Bool, placeName: String,
                       _ completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        database.collection(id).document(placeName)
            .updateData([PlaceData.favorit: favorit]) { error in
                if error != nil {
                    completion(.failure(.save))
                    return
                }
                
                completion(.success(()))
            }
    }
    
    private func setupBasicClassification(_ completion: @escaping (Result<([String], [String]), FirebaseError>) -> Void) {
        database.collection(Classification.collection).document(id)
            .setData(Classification.basic) { error in
                if error != nil {
                    completion(.success(([], [])))
                }
                
                self.loadClassification(completion)
            }
    }
}

private extension FirestoreManager {
    enum Classification {
        static let collection = "classification"
        static let basic: [String: [String]] = [PlaceData.category: ["카페", "음식점", "디저트", "전시회", "액티비티", "야외"],
                                                PlaceData.group: ["친구", "가족", "애인", "혼자"]]
    }
    
    enum PlaceData {
        static let name = "name"
        static let location = "position"
        static let date = "date"
        static let favorit = "favorit"
        static let rating = "rate"
        static let coment = "coment"
        static let category = "category"
        static let geopoint = "geopoint"
        static let group = "group"
    }
}
