//
//  ImageCacheManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2022/12/16.
//

import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
