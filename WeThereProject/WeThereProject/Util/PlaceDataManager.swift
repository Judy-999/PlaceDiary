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
        FirestoreManager.shared.loadData() { [weak self] result in
            switch result {
            case .success(let places):
                self?.places = places
                completion(places)
            case .failure(_):
                completion([])
            }
        }
    }
    
    func getPlaces() -> [Place] {
        return places
    }
    
    func setupPlaces(with newPlaces: [Place]) {
        places = newPlaces
    }
}
