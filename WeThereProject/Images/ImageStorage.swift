//
//  ImageStorage.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/05.
//

import Foundation
import UIKit

extension PlaceImage{
    static func build(from fileImages: [UIImage?], imageName: [PlaceData]) -> [PlaceImage]{
        var images = [PlaceImage]()
        
        for i in 0 ..< imageName.count{
            images.append(PlaceImage(imageName: imageName[i].name!, iamge: fileImages[i]!))
            
        }
        return images
    }
}


