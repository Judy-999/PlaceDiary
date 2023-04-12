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
    
    func save(_ image: UIImage, with name: String) {
        let cachedKey = NSString(string: name)
        cache.setObject(image, forKey: cachedKey)
    }
    
    func getImage(with name: String) -> UIImage? {
        let cachedKey = NSString(string: name)
        return cache.object(forKey: cachedKey)
    }
}
