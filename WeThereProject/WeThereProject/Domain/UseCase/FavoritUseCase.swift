//
//  FavoritUseCase.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/24.
//

import RxSwift

struct FavoritUseCase {
    private let placeRepository: PlaceRepository
    
    init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
    }
    
    func update(_ place: String, _ isFavorit: Bool) -> Observable<Void> {
        return placeRepository.updateFavorit(isFavorit, placeName: place)
    }
}
