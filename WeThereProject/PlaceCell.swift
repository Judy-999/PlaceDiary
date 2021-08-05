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
        if data.image == true {
            let fileUrl = "gs://wethere-2935d.appspot.com/" + imageName
            Storage.storage().reference(forURL: fileUrl).downloadURL { [self] url, error in
                let data = NSData(contentsOf: url!)
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    self.imgPlace.image = downloadImg
                    placeImages.updateValue(downloadImg!, forKey: imageName)
                    print("image download!!!셀셀셀" + imageName)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endLoading"), object: nil)
                }
            }
        }else{
            /*
                self.imgPlace.image = UIImage(named: "example.jpeg")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endLoading"), object: nil)
 */
            let fileUrl = "gs://wethere-2935d.appspot.com/" + "defaultImage_original"
            Storage.storage().reference(forURL: fileUrl).downloadURL { [self] url, error in
                let data = NSData(contentsOf: url!)
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    self.imgPlace.image = downloadImg
                    placeImages.updateValue(downloadImg!, forKey: imageName)
                    print("image download!!!셀셀셀" + imageName)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endLoading"), object: nil)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
