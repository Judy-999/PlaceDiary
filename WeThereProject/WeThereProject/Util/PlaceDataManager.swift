//
//  PlaceDataManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/17.
//

final class PlaceDataManager {
    static let shared = PlaceDataManager()
    private var places = [Place]()
    private var classification = Classification()
    
    private init() { }
    
    func getPlaces() -> [Place] {
        return places
    }
    
    func setupPlaces(with newPlaces: [Place]) {
        places = newPlaces
    }
    
    func getClassification() -> Classification {
        return classification
    }
    
    func setupClassification(with new: [String], type: EditType) {
        switch type {
        case .category:
            classification = Classification(category: new, group: classification.group)
        case .group:
            classification = Classification(category: classification.category, group: new)
        }
    }
}
