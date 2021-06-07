//
//  ImageService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/05.
//

import Foundation
import FirebaseStorage

class ImageService {

    func getImage(imageName: [PlaceData], handler: @escaping  ([PlaceImage]) -> ()) {
        var storageImages = [UIImage]()
        let ref = Storage.storage().reference()

        for i in 0 ..< imageName.count {
            ref.child(imageName[i].name!).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error == nil {
                storageImages.append(UIImage(data: data!)!)
                print("image download!!!")
                } else {
                
                }
            }
        }
        handler(PlaceImage.build(from: storageImages, imageName: imageName))
    }
}
