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
    
    let storage = Storage.storage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func getImage(place: PlaceData, completion: @escaping (UIImage?) -> ()) {
        let fileName = place.name
        if place.image == true {
            let islandRef = storage.reference().child(Uid + "/" + fileName)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    completion(downloadImg)
                    print("image download!!!" + fileName)
                } else {
                        completion(nil)
                }
            }
        }else{
            let basicImg = UIImage(named: "wethere.jpeg")
            completion(basicImg)
        }
    }
    
    func setImage(_ data: PlaceData) -> UIImage {
        let imageName = data.name
        var returnImg : UIImage?
        if data.image == true {
            let islandRef = storage.reference().child(Uid + "/" + imageName)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                let downloadImg = UIImage(data: data! as Data)
                if error == nil {
                    DispatchQueue.main.async {
                        self.imgPlace.image = downloadImg
                        returnImg = downloadImg
                    }
                    print("image download!!!셀셀셀" + imageName)
                    
              //      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateImg"), object: newData)
                }
            }
            return returnImg!
        }else{
            returnImg = UIImage(named: "wethere.jpeg")
            return returnImg!
        }
    }
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
