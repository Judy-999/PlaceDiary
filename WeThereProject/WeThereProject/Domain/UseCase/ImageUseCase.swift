//
//  ImageUseCase.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/27.
//

import RxSwift
import UIKit

struct ImageUseCase {
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository = ImageRepository()) {
        self.imageRepository = imageRepository
    }
    
    func load(_ name: String) -> Observable<UIImage> {
        return imageRepository.load(name)
    }
    
    func save(_ image: UIImage, with name: String) -> Observable<Void> {
        return imageRepository.save(image, with: name)
    }
    
    func delte(_ name: String) -> Observable<Void> {
        return imageRepository.delete(name)
    }
}
