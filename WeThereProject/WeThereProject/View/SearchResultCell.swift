//
//  SearchResultCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/07/09. --> Refacted on 2022/12/15
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
