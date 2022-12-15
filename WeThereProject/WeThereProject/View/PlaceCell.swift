//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28. --> Refacted on 2022/12/15
//

import UIKit
import FirebaseStorage

class PlaceCell: UITableViewCell {
    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPlaceDate: UILabel!
    @IBOutlet weak var lblPlaceInfo: UILabel!
    @IBOutlet weak var btnFavorit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
