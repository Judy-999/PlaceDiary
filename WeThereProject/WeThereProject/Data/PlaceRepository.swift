//
//  PlaceRepository.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/23.
//

import RxSwift
import FirebaseFirestore

struct PlaceRepository {
    func loadPlaces() -> Observable<[Place]> {
        let snapshot = FirestoreManager.shared.loadCollection()
        return snapshot.map { document in
            document.compactMap { toPlaces($0) }
        }
    }
    
    func loadClassification() -> Observable<Classification> {
        let document = FirestoreManager.shared.loadDocument(at: ClassificationData.collection)
        
        return document
            .do(onError: { error in
                if error as? ClassificationError == .empty {
                    setupBasicClassification()
                }
            })
            .compactMap { toClassfication($0) }
            .catchAndReturn(ClassificationData.basic)
    }
    
    func updateClassification(_ classification: String,
                              with items: [String]) -> Observable<Void> {
        let data = [classification: items]
        return FirestoreManager.shared.update(data,
                                              at: ClassificationData.collection,
                                              document: nil)
    }
    
    func updateFavorit(_ favorit: Bool, placeName: String) -> Observable<Void> {
        let data = [PlaceData.favorit: favorit]
        return FirestoreManager.shared.update(data,
                                              at: nil,
                                              document: placeName)
    }
    
    func deletePlace(_ placeName: String) -> Observable<Void> {
        return FirestoreManager.shared.delete(placeName)
    }
    
    func savePlace(_ place: Place) -> Observable<Void> {
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
        
        return FirestoreManager.shared.save(saveData,
                                            at: nil,
                                            document: place.name)
    }
    
    private func setupBasicClassification() {
        let basicClassification = [PlaceData.group: ClassificationData.basicGroup,
                                   PlaceData.category: ClassificationData.basicCategory]
        _ = FirestoreManager.shared.save(basicClassification,
                                                at: ClassificationData.collection,
                                                document: nil)
    }
}

extension PlaceRepository {
    private func toClassfication(_ document: DocumentSnapshot) -> Classification? {
        guard let categories = document.get(PlaceData.category) as? [String],
              let groups = document.get(PlaceData.group) as? [String] else { return nil }
        
        return Classification(category: categories, group: groups)
    }
    
    private func toPlaces(_ document: DocumentSnapshot) -> Place? {
        guard let name = document[PlaceData.name] as? String,
              let location = document[PlaceData.location] as? String,
              let date = document[PlaceData.date] as? Timestamp,
              let isFavorit = document[PlaceData.favorit] as? Bool,
              let category = document[PlaceData.category] as? String,
              let rating = document[PlaceData.rating] as? String,
              let coment = document[PlaceData.coment] as? String,
              let geopoint = document[PlaceData.geopoint] as? GeoPoint,
              let group = document[PlaceData.geopoint] as? String else { return nil }
        
       return Place(name: name,
                    location: location,
                    date: date.dateValue(),
                    isFavorit: isFavorit,
                    category: category,
                    rating: rating,
                    coment: coment,
                    geopoint: geopoint,
                    group: group)
    }
}
