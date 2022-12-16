//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28. --> Refacted on 2022/12/15
//

import UIKit
import FirebaseStorage

class PlaceCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var favoritButton: UIButton!
    
    private var placeName = ""
    
    func configure(with place: Place) {
        nameLabel.text = place.name
        infoLabel.text = "\(place.group) ∙ \(place.category) ∙ \(place.rate) 점"
        
        if place.isFavorit {
            favoritButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoritButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        placeName = place.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = formatter.string(from: place.date)
        
        configureImage(with: place)
    }
    
    private func configureImage(with place: Place) {
        placeImageView.image = UIImage(named: "pdicon")
        guard place.hasImage == true else { return }
        let cachedKey = NSString(string: place.name)
        
        if let placeImage = ImageCacheManager.shared.object(forKey: cachedKey) {
            placeImageView.image = placeImage
        } else {
            StorageManager.shared.getImage(name: place.name) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.placeImageView.image = image
                    }
                    
                    ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.image = UIImage(named: "pdicon")
        placeName = ""
    }
    
    @IBAction private func favoritButtonTapped(_ sender: UIButton) {
        let isFavorit: Bool
        
        if sender.currentImage == UIImage(systemName: "heart") {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            isFavorit = true
        } else {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            isFavorit = false
        }
        
        FirestoreManager.shared.updateFavorit(isFavorit, placeName: placeName)
    }
}
