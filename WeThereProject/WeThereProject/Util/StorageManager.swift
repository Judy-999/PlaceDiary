//
//  StorageManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2022/12/16.
//

import UIKit
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    
    func getImage(name: String, completion: @escaping (UIImage?) -> ()) {
        let size: Int64 = 1024 * 1024
        storage.child(Uid + "/" + name).getData(maxSize: size) { data, error in
            if error != nil {
                completion(nil)
            }
            
            if let data = data {
                completion(UIImage(data: data))
            }
        }
    }
    
    func deleteImage(name: String) {
        storage.child(Uid + "/" + name).delete { error in
            if let error = error {
                print("Error removing image: \(error)")
            } else {
                print("Image successfully removed!")
            }
        }
    }
}
