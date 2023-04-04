//
//  AddViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import RxSwift
import RxRelay
import UIKit

struct AddViewModel {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var errorMessage = PublishRelay<String>()
    
    private let placeUseCase: PlaceUseCase
    private let imageUseCase: ImageUseCase

    init(placeUseCase: PlaceUseCase,
         imageUseCase: ImageUseCase) {
        self.placeUseCase = placeUseCase
        self.imageUseCase = imageUseCase
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
