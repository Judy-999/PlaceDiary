//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//
import Foundation
import Firebase

struct PlaceData {
    var name: String?
    var position: String?
    var date: Date?
    var visit: Bool?
    var tag = [String]()
    var category : String?
    var rate: String?
    var coment: String?
    var geopoint: GeoPoint?
    
  /*  init?(dictionary: [String:Any]){
        self.name = dictionary["name"] as? String
        self.position = dictionary["position"] as? String
        self.date = dictionary["date"] as? Date
        self.visit = dictionary["visit"] as? Bool
        self.tag = (dictionary["tag"] as? [String])!
    }
 */
}
