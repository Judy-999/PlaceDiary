//
//  Place.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/02. --> refacted on 2022/12/14.
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
}
