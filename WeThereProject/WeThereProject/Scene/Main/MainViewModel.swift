//
//  MainViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/24.
//

import RxCocoa
import RxSwift
import UIKit

protocol MainViewModelInput {
    func loadPlaceData(_ disposeBag: DisposeBag)
    func deletePlace(_ place: String, _ disposeBag: DisposeBag)
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) 
}

protocol MainViewModelOutput {
    var places: BehaviorRelay<[Place]> { get }
    var errorMessage: PublishRelay<String> { get }
}

struct MainViewModel: MainViewModelInput, MainViewModelOutput {
    var refreshing = BehaviorSubject<Bool>(value: false)
    var places = BehaviorRelay<[Place]>(value: [])
    var classification = PublishRelay<Classification>()
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase = PlaceUseCase()
    let classificationUseCase = ClassificationUseCase()

    func loadPlaceData(_ disposeBag: DisposeBag) {
        refreshing.onNext(true)
        
        placeUseCase.fetch()
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
    
    func deletePlace(_ place: String, _ disposeBag: DisposeBag) {
        placeUseCase.delete(place)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) {
        placeUseCase.save(place)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func loadClassification(_ disposeBag: DisposeBag) {
        classificationUseCase.fetch()
            .bind(to: classification)
            .disposed(by: disposeBag)
    }
    
    func updateClassification(type: String,
                              _ classfications: [String],
                              _ disposeBag: DisposeBag) {
        classificationUseCase.update(type, classfications)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}


