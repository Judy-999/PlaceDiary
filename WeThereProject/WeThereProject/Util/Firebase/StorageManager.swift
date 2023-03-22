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
        id = DeviceKeyManager.shared.read()
    }
    
    func saveImage(_ image: UIImage, name: String,
                   completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storage.child(id + "/" + name).putData(imageData, metadata: metaData) { _ , error in
            if error != nil {
                completion(.failure(.save))
                return
            }
            
            completion(.success(()))
        }
    }
    
    func getImage(name: String,
                  completion: @escaping (Result<UIImage, FirebaseError>) -> Void) {
        let size: Int64 = 1024 * 1024
        storage.child(id + "/" + name).getData(maxSize: size) { data, error in
            if error != nil {
                completion(.failure(.fetch))
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
    }
    
    func deleteImage(name: String,
                     completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        storage.child(id + "/" + name).delete { error in
            if error != nil {
                completion(.failure(.delete))
                return
            }
            
            completion(.success(()))
        }
    }
}
