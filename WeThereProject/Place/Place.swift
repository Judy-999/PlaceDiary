//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02.
//
import Foundation


struct PlaceData {
    let name: String?
    let position: String?
    let date: Date?
    let visit: Bool?
    let tag = [String]()
    let category : String?
    let rate: String?
    
  /*  init?(dictionary: [String:Any]){
        self.name = dictionary["name"] as? String
        self.position = dictionary["position"] as? String
        self.date = dictionary["date"] as? Date
        self.visit = dictionary["visit"] as? Bool
        self.tag = (dictionary["tag"] as? [String])!
    }
 */
}
