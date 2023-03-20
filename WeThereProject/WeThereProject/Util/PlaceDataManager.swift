//
//  PlaceDataManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/17.
//

final class PlaceDataManager {
    static let shared = PlaceDataManager()
    private var places = [Place]()
    private var classification: (category: [String], group: [String]) = ([], [])
    
    private init() { }
    
    func loadPlaces(_ completion: @escaping (Result<[Place], FirebaseError>) -> Void) {
        FirestoreManager.shared.loadData { [weak self] result in
            switch result {
            case .success(let success):
                self?.places = success
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func getPlaces() -> [Place] {
        return places
    }
    
    func setupPlaces(with newPlaces: [Place]) {
        places = newPlaces
    }
    
    func loadClassification(_ completion: @escaping (Result<([String], [String]), FirebaseError>) -> Void) {
        FirestoreManager.shared.loadClassification { [weak self] result in
            switch result {
            case .success(let success):
                completion(.success(success))
                self?.classification = success
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func getClassification() -> ([String], [String]) {
        return classification
    }
    
    func setupClassification(with new: [String], type: EditType) {
        switch type {
        case .category:
            classification.category = new
        case .group:
            classification.group = new
        }
    }
}
