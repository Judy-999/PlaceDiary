//
//  PlaceDataManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/17.
//

final class PlaceDataManager {
    static let shared = PlaceDataManager()
    private var places: [Place] = []
    
    private init() { }
    
    func load(completion: @escaping ([Place]) -> ()) {
        FirestoreManager.shared.loadData() { [weak self] places in
            self?.places = places
            completion(places)
        }
    }
    
    func getPlaces() -> [Place] {
        return places
    }
    
    func setupPlaces(with newPlaces: [Place]) {
        places = newPlaces
    }
}
