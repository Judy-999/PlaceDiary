//
//  ImageCacheManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2022/12/16.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func setupImage(with name: String, completion: @escaping (UIImage?) -> ()) {
        let cachedKey = NSString(string: name)
        
        if let image = cache.object(forKey: cachedKey) {
            completion(image)
            return
        }
    
        StorageManager.shared.getImage(name: name) { image in
            if let image = image {
                self.cache.setObject(image, forKey: cachedKey)
                completion(image)
            } else {
                completion(DiaryImage.placeholer)
            }
        }
    }
    
    func updateImage(with name: String, new: String, _ image: UIImage) {
        let oldCachedKey = NSString(string: name)
        let newCachedKey = NSString(string: new)
        cache.removeObject(forKey: oldCachedKey)
        cache.setObject(image, forKey: newCachedKey)
    }
}
