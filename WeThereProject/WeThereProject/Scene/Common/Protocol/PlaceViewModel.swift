//
//  PlaceViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import RxCocoa
import RxSwift
import UIKit

protocol DefaultViewModelType {
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
}

extension DefaultViewModelType {
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

protocol PlaceViewModel: DefaultViewModelType {
    var action: PlaceViewModelAction { get }
    func showPlaceDetail(_ place: Place)
    func showPlaceAdd(with place: Place?)
}

extension PlaceViewModel {
    func showPlaceDetail(_ place: Place) {
        action.showPlaceDetails(place, self)
    }
    
    func showPlaceAdd(with place: Place? = nil) {
        action.showPlaceAdd(place, self)
    }
}
