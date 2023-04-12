//
//  StorageManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2022/12/16.
//

import UIKit
import RxSwift
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    private let id: String
    
    private init() {
        id = DeviceKeyManager.shared.read()
    }
    
    func saveImage(_ image: UIImage, name: String) -> Observable<Void> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return Observable.empty() }
        let reference = storage.child(id + "/" + name)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
    
        return Observable.create { observable in
            reference.putData(imageData, metadata: metaData) { _ , error in
                if error != nil {
                    observable.onError(FirebaseError.save)
                }
                
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func getImage(name: String) -> Observable<UIImage> {
        let size: Int64 = 1024 * 1024
        let reference = storage.child(id + "/" + name)
        return Observable.create { observable in
            reference.getData(maxSize: size) { data, error in
                if error != nil {
                    observable.onError(FirebaseError.fetch)
                }
                
                if let data = data, let image = UIImage(data: data) {
                    observable.onNext(image)
                }
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func deleteImage(name: String) -> Observable<Void> {
        let reference = storage.child(id + "/" + name)
        return Observable.create { observable in
            reference.delete { error in
                if error != nil {
                    observable.onError(FirebaseError.delete)
                }
                
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
}
