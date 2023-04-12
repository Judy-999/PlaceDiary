//
//  MainViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/24.
//

import RxCocoa
import RxSwift
import UIKit

struct PlaceViewModelAction {
    let showPlaceDetails: (Place, any PlaceViewModel) -> Void
    let showPlaceAdd: (Place?, any PlaceViewModel) -> Void
}

struct MainViewModel: PlaceViewModel {
    var refreshing = BehaviorSubject<Bool>(value: false)
    var places = BehaviorRelay<[Place]>(value: [])
    var classification = BehaviorRelay<Classification>(value: Classification())
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    let classificationUseCase: ClassificationUseCase
    let imageUseCase: ImageUseCase
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
    
    func loadPlaceData(_ disposeBag: DisposeBag) {
        refreshing.onNext(true)
        
        placeUseCase.fetch()
            .take(1)
            .do(onNext: { _ in
                refreshing.onNext(false)
            })
            .subscribe(
                onNext: { placeData in
                    places.accept(placeData)
                },
                onError: { error in
                    errorMessage.accept(error.localizedDescription)
                })
            .disposed(by: disposeBag)
    }
    
    func loadClassification(_ disposeBag: DisposeBag) {
        classificationUseCase.fetch()
            .take(1)
            .bind(to: classification)
            .disposed(by: disposeBag)
    }
    
    func updateClassification(type: String,
                              _ classfications: [String],
                              _ disposeBag: DisposeBag) {
        classificationUseCase.update(type, classfications)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
