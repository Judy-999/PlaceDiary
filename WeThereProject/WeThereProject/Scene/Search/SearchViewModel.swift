//
//  SearchViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/10.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchViewModelAction {
    let showPlaceDetails: (Place, SearchViewModel) -> Void
}

struct SearchViewModel: PlaceViewModel {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var places = BehaviorRelay<[Place]>(value: [])
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    var imageUseCase: ImageUseCase = ImageUseCase()
    let action: SearchViewModelAction

    init(placeUseCase: PlaceUseCase,
        action: SearchViewModelAction) {
        self.placeUseCase = placeUseCase
        self.action = action
    }
    
    func loadPlaceData(_ disposeBag: DisposeBag) {
        placeUseCase.fetch()
            .take(1)
            .subscribe(
                onNext: { placeData in
                    places.accept(placeData)
                },
                onError: { error in
                    errorMessage.accept(error.localizedDescription)
                })
            .disposed(by: disposeBag)
    }
}

extension SearchViewModel {
    func showPlaceDetail(_ place: Place) {
        action.showPlaceDetails(place, self)
    }
    
    func showPlaceAdd(with place: Place? = nil) {
        
    }
}
