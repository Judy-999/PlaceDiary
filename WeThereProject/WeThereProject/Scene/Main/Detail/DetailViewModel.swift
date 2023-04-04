//
//  DetailViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import RxSwift
import RxRelay
import UIKit

struct DetailViewModelAction {
    let showPlaceAdd: (Place?) -> Void
}

struct DetailViewModel {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var errorMessage = PublishRelay<String>()
    
    private let placeUseCase: PlaceUseCase
    private let imageUseCase: ImageUseCase
    private let action: DetailViewModelAction

    init(placeUseCase: PlaceUseCase,
         imageUseCase: ImageUseCase,
         action: DetailViewModelAction) {
        self.placeUseCase = placeUseCase
        self.imageUseCase = imageUseCase
        self.action = action
    }
    
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) { 
        placeUseCase.save(place)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func deletePlace(_ name: String, _ disposeBag: DisposeBag) {
        placeUseCase.delete(name)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        imageUseCase.delte(name)
            .take(1)
            .subscribe(onError: { error in
            errorMessage.accept(error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
}

extension DetailViewModel {
    func showPlaceAdd(with place: Place) {
        action.showPlaceAdd(place)
    }
}
