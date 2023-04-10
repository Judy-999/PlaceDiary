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

final class MainViewModel: MainViewModelInput, MainViewModelOutput {
    var refreshing = BehaviorSubject<Bool>(value: false)
    var places = BehaviorRelay<[Place]>(value: [])
    var classification = BehaviorRelay<Classification>(value: Classification())
    var errorMessage = PublishRelay<String>()
    
    private let placeUseCase: PlaceUseCase
    let classificationUseCase = ClassificationUseCase()
    let imageUseCase = ImageUseCase()
    private let action: PlaceViewModelAction

    init(placeUseCase: PlaceUseCase,
        action: PlaceViewModelAction?) {
        self.placeUseCase = placeUseCase
        self.action = action!
    }
    
    func loadPlaceData(_ disposeBag: DisposeBag) {
        refreshing.onNext(true)
        
        placeUseCase.fetch()
            .take(1)
            .do(onNext: { [weak self] _ in
                self?.refreshing.onNext(false)
            })
            .subscribe(
                onNext: { [weak self] placeData in
                    self?.places.accept(placeData)
                },
                onError: { [weak self] error in
                    self?.errorMessage.accept(error.localizedDescription)
                })
            .disposed(by: disposeBag)
    }
    
    func deletePlace(_ place: String, _ disposeBag: DisposeBag) {
        placeUseCase.delete(place)
            .take(1)
            .subscribe(onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func savePlace(_ place: Place, _ disposeBag: DisposeBag) {
        placeUseCase.save(place)
            .take(1)
            .subscribe(onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
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
            .subscribe(onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func loadImage(_ name: String) -> Observable<UIImage> {
        return imageUseCase.load(name)
    }
    
    func deleteImage(_ name: String, _ disposeBag: DisposeBag) {
        imageUseCase.delte(name)
            .take(1)
            .subscribe(onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
    
    func saveImage(_ image: UIImage, with name: String, _ disposeBag: DisposeBag) {
        imageUseCase.save(image, with: name)
            .take(1)
            .subscribe(onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
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
