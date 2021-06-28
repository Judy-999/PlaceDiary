//
//  CollectionViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/27.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var groupImage: UIImageView!
    @IBOutlet var grouplbl: UILabel!
    
    func updateCell(_ info: GroupInfo){
        groupImage.image = info.image
        grouplbl.text = info.name
    }
}
