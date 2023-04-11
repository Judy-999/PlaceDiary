//
//  MainViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/24.
//

import RxCocoa
import RxSwift
import UIKit

protocol PlaceViewModel {
    var places: BehaviorRelay<[Place]> { get }
    var errorMessage: PublishRelay<String> { get }
    var classification: BehaviorRelay<Classification> { get }
    var placeUseCase: PlaceUseCase { get }
    var imageUseCase: ImageUseCase { get }
    
    func loadPlaceData(_ disposeBag: DisposeBag)
    func deletePlace(_ place: String, _ disposeBag: DisposeBag)
    func savePlace(_ place: Place, _ disposeBag: DisposeBag)
    func deleteImage(_ name: String, _ disposeBag: DisposeBag)
    func saveImage(_ image: UIImage, with name: String, _ disposeBag: DisposeBag)
    func showPlaceAdd(with place: Place?)
    func showPlaceDetail(_ place: Place)
}

struct PlaceViewModelAction {
    let showPlaceDetails: (Place, MainViewModel) -> Void
    let showPlaceAdd: (Place?, MainViewModel) -> Void
}

protocol MainViewModelInput {
    func loadPlaceData(_ disposeBag: DisposeBag)
    func deletePlace(_ place: String, _ disposeBag: DisposeBag)
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) 
}

protocol MainViewModelOutput {
    var places: BehaviorRelay<[Place]> { get }
    var errorMessage: PublishRelay<String> { get }
}

struct MainViewModel: MainViewModelInput, MainViewModelOutput, PlaceViewModel {
    var refreshing = BehaviorSubject<Bool>(value: false)
    var places = BehaviorRelay<[Place]>(value: [])
    var classification = BehaviorRelay<Classification>(value: Classification())
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    let classificationUseCase = ClassificationUseCase()
    let imageUseCase = ImageUseCase()
    let action: PlaceViewModelAction

    init(placeUseCase: PlaceUseCase,
        action: PlaceViewModelAction) {
        self.placeUseCase = placeUseCase
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


extension MainViewModel {
    func showPlaceAdd(with place: Place? = nil) {
        action.showPlaceAdd(place, self)
    }

    func showPlaceDetail(_ place: Place) {
        action.showPlaceDetails(place, self)
    }
}

extension PlaceViewModel {
    func deletePlace(_ place: String, _ disposeBag: DisposeBag) {
        placeUseCase.delete(place)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) {
        placeUseCase.save(place)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func loadImage(_ name: String) -> Observable<UIImage> {
        return imageUseCase.load(name)
    }
    
    func deleteImage(_ name: String, _ disposeBag: DisposeBag) {
        imageUseCase.delte(name)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
    
    func saveImage(_ image: UIImage, with name: String, _ disposeBag: DisposeBag) {
        imageUseCase.save(image, with: name)
            .take(1)
            .subscribe(onError: { error in
                errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
