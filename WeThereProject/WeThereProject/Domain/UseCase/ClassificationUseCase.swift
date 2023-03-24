//
//  ClassificationUseCase.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/23.
//

import RxSwift

struct ClassificationUseCase {
    private let placeRepository: PlaceRepository
    
    init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
    }
    
    func fetch() -> Observable<Classification> {
        return placeRepository.loadClassification()
    }
    
    func update(_ type: String, _ classificationList: [String]) -> Observable<Void> {
        return placeRepository.updateClassification(type, with: classificationList)
    }
}
