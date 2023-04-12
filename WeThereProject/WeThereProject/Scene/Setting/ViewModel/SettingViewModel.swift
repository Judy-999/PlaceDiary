//
//  SettingViewModel.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/11.
//

import RxSwift
import RxCocoa

struct SettingViewModelAction {
    let showEditClassification: (ClassificationType, SettingViewModel) -> Void
    let showStatistics: (SettingViewModel) -> Void
}

struct SettingViewModel: DefaultViewModelType {
    var classification = BehaviorRelay<Classification>(value: Classification())
    var places = BehaviorRelay<[Place]>(value: [])
    var errorMessage = PublishRelay<String>()
    
    let placeUseCase: PlaceUseCase
    let imageUseCase: ImageUseCase = ImageUseCase()
    let classificationUseCase: ClassificationUseCase = ClassificationUseCase()
    let action: SettingViewModelAction

    init(placeUseCase: PlaceUseCase,
         action: SettingViewModelAction) {
        self.placeUseCase = placeUseCase
        self.action = action
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

extension SettingViewModel {
    func showEditClassification(type: ClassificationType) {
        action.showEditClassification(type, self)
    }
    
    func showStatistics() {
        action.showStatistics(self)
    }
}
