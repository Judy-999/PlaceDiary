//
//  StorageManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2022/12/16.
//

import UIKit
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    private let id: String
    
    private init() {
        guard let collectionID = UIDevice.current.identifierForVendor?.uuidString else {
            id = ""
            return
        }
        
        id = collectionID
    }
    
    func saveImage(_ image: UIImage, name: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storage.child(id + "/" + name).putData(imageData, metadata: metaData) { (metaData, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Image successfully upload!")
            }
        }
    }
    
    func getImage(name: String, completion: @escaping (UIImage?) -> ()) {
        let size: Int64 = 1024 * 1024
        storage.child(id + "/" + name).getData(maxSize: size) { data, error in
            if error != nil {
                completion(nil)
            }
            
            if let data = data {
                completion(UIImage(data: data))
            }
        }
    }
    
    func deleteImage(name: String) {
        storage.child(id + "/" + name).delete { error in
            if let error = error {
                print("Error removing image: \(error)")
            } else {
                print("Image successfully removed!")
            }
        }
    }
}
