//
//  PlaceUseCase.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/23.
//

import RxSwift

struct PlaceUseCase {
    private let placeRepository: PlaceRepository
    
    init(placeRepository: PlaceRepository = PlaceRepository()) {
        self.placeRepository = placeRepository
    }
    
    func fetch() -> Observable<[Place]> {
        return placeRepository.loadPlaces()
    }
    
    func delete(_ placeName: String) -> Observable<Void> {
        return placeRepository.deletePlace(placeName)
    }
    
    func save(_ place: Place) -> Observable<Void> {
        return placeRepository.savePlace(place)
    }
}

