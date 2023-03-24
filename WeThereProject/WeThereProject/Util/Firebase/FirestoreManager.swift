//
//  PlaceService.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//

import RxSwift
import FirebaseFirestore
import UIKit

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let database = Firestore.firestore()
    private let id: String
    
    private init() {
        id = UIDevice.current.identifierForVendor!.uuidString
    }
    
    func loadCollection() -> Observable<[QueryDocumentSnapshot]> {
        let query = database.collection(id).order(by: PlaceData.date, descending: true)
        return Observable.create { observable in
            query.addSnapshotListener { querySnapshot, error in
                if error != nil {
                    observable.onError(FirebaseError.fetch)
                }
                
                if let documents = querySnapshot?.documents {
                    observable.onNext(documents)
                }
                observable.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func loadDocument(at collection: String) -> Observable<DocumentSnapshot> {
        let reference = database.collection(ClassificationData.collection).document(id)
        return Observable.create { observable in
            reference.getDocument { document, error in
                if error != nil {
                    observable.onError(FirebaseError.fetch)
                }
                
                if let document = document {
                    if document.exists == false {
                        observable.onError(ClassificationError.empty)
                    }
                    observable.onNext(document)
                }
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }

    func save(_ data: [String: Any], at collection: String?, document: String?) -> Observable<Void> {
        let collection = collection ?? id
        let document = document ?? id
        let reference = database.collection(collection).document(document)
        return Observable.create { observable in
            reference.setData(data) { error in
                if error != nil {
                    observable.onError(FirebaseError.delete)
                }
                
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func update(_ data: [String: Any],
                at collection: String?,
                document: String?) -> Observable<Void> {
        let collection = collection ?? id
        let document = document ?? id
        let reference = database.collection(collection).document(document)
        
        return Observable.create { observable in
            reference.updateData(data) { error in
                if error != nil {
                    observable.onError(FirebaseError.save)
                    return
                }
                
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func delete(_ document: String) -> Observable<Void> {
        let reference = database.collection(id).document(document)
        return Observable.create { observable in
            reference.delete() { error in
                if error != nil {
                    observable.onError(FirebaseError.delete)
                }
                
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
}


enum ClassificationData {
    static let collection = "classification"
    static let basicCategory = ["카페", "음식점", "디저트", "전시회", "액티비티", "야외"]
    static let basicGroup = ["친구", "가족", "애인", "혼자"]
    static let basic = Classification(category: basicCategory, group: basicGroup)
}

enum PlaceData {
    static let name = "name"
    static let location = "position"
    static let date = "date"
    static let favorit = "favorit"
    static let rating = "rate"
    static let coment = "coment"
    static let category = "category"
    static let geopoint = "geopoint"
    static let group = "group"
}
