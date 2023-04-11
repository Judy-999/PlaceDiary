//
//  MapViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/11.
//

import RxSwift
import RxCocoa

struct MapViewModel: PlaceViewModel {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var places = BehaviorRelay<[Place]>(value: [])
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    let imageUseCase: ImageUseCase = ImageUseCase()
    let action: PlaceViewModelAction

    init(placeUseCase: PlaceUseCase,
        action: PlaceViewModelAction) {
        self.placeUseCase = placeUseCase
        self.action = action
    }
}
