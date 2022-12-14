//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28. --> refacted on 2022/12/14.
//

import UIKit
import FirebaseStorage

class PlaceCell: UITableViewCell {
    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPlaceDate: UILabel!
    @IBOutlet weak var lblPlaceInfo: UILabel!
    @IBOutlet weak var lblPlaceRate: UILabel!
    @IBOutlet weak var starImageView: UIImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
