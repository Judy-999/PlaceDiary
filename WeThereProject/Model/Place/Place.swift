//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//
import Foundation
import Firebase
import UIKit

struct PlaceData {
    var name: String
    var location: String
    var date: Date
    var visit: Bool
    var image: Bool
    var count: String
    var category : String
    var rate: String
    var coment: String
    var geopoint: GeoPoint
    var group: String
    var newImg: UIImage?
    
    /*
    var image: UIImage?{
        let fileUrl = "gs://wethere-2935d.appspot.com/" + name
        var img: UIImage?
        Storage.storage().reference(forURL: fileUrl).downloadURL { url, error in
            let data = NSData(contentsOf: url!)
            let downloadImg = UIImage(data: data! as Data)
            if error == nil {
                img = downloadImg!
                print("image download 소큐소큐소큐" + name)
            } else {
                print("error")
            }
        }
        return img
    }
    */
    
  /*  init?(dictionary: [String:Any]){
        self.name = dictionary["name"] as? String
        self.position = dictionary["position"] as? String
        self.date = dictionary["date"] as? Date
        self.visit = dictionary["visit"] as? Bool
        self.tag = (dictionary["tag"] as? [String])!
    }
 */
}
