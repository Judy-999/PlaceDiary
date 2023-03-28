//
//  ImageRepository.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/27.
//

import RxSwift
import UIKit

extension ObservableType where Element == (String, UIImage) {
    func cache() -> Observable<Element> {
        return self.do(onNext: { (name, image) in
            ImageCacheManager.shared.save(image, with: name)
        })
    }
}

struct ImageRepository {
    func load(_ name: String) -> Observable<UIImage> {
        if let image = ImageCacheManager.shared.getImage(with: name) {
            return Observable.just(image)
        }
        
        return StorageManager.shared.getImage(name: name)
            .map { (name, $0) }
            .cache()
            .map { _, image in image }
    }
    
    func save(_ image: UIImage, with name: String) -> Observable<Void> {
        return StorageManager.shared.saveImage(image, name: name)
    }
    
    func delete(_ name: String) -> Observable<Void> {
        return StorageManager.shared.deleteImage(name: name)
    }
}
