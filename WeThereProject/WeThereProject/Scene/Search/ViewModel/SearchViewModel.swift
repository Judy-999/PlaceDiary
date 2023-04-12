//
//  SearchViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/10.
//

import RxSwift
import RxCocoa

struct SearchViewModel: PlaceViewModel {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var places = BehaviorRelay<[Place]>(value: [])
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    let imageUseCase: ImageUseCase
    let action: PlaceViewModelAction

    init(placeUseCase: PlaceUseCase,
         imageUseCase: ImageUseCase,
         action: PlaceViewModelAction) {
        self.placeUseCase = placeUseCase
        self.imageUseCase = imageUseCase
        self.action = action
    }
}
