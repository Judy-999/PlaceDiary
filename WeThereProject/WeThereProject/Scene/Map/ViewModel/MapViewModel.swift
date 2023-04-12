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
    let imageUseCase: ImageUseCase
    let classificationUseCase: ClassificationUseCase
    let action: PlaceViewModelAction

    init(placeUseCase: PlaceUseCase,
         imageUseCase: ImageUseCase,
         classificationUseCase: ClassificationUseCase,
         action: PlaceViewModelAction) {
        self.placeUseCase = placeUseCase
        self.imageUseCase = imageUseCase
        self.classificationUseCase = classificationUseCase
        self.action = action
    }
    
    func loadClassification(_ disposeBag: DisposeBag) {
        classificationUseCase.fetch()
            .take(1)
            .bind(to: classification)
            .disposed(by: disposeBag)
    }
}
