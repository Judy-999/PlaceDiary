//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28.
//

import UIKit
import FirebaseStorage



class PlaceCell: UITableViewCell {

    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPlaceLocation: UILabel!
    @IBOutlet weak var lblPlaceInfo: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func setImage(_ data: PlaceData){
        let imageName = data.name
        var newData = data
        if data.image == true {
            let fileUrl = "gs://wethere-2935d.appspot.com/" + imageName + "_original"
            Storage.storage().reference(forURL: fileUrl).downloadURL { [self] url, error in
                let data = NSData(contentsOf: url!)
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    DispatchQueue.main.async {
                        self.imgPlace.image = downloadImg
                    }
                    print("image download!!!셀셀셀" + imageName)
                    newData.orgImg = downloadImg
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateImg"), object: newData)
                }
            }
        }else{
            let fileUrl = "gs://wethere-2935d.appspot.com/" + "defaultImage_original"
            Storage.storage().reference(forURL: fileUrl).downloadURL { [self] url, error in
                let data = NSData(contentsOf: url!)
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    self.imgPlace.image = downloadImg
                    newData.orgImg = downloadImg
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateImg"), object: newData)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
