//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28. --> Refacted on 2022/12/15
//

import UIKit

final class PlaceCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var favoritButton: UIButton!
    
    private var placeName = ""
    
    func configure(with place: Place) {
        let favoritImage = place.isFavorit ? DiaryImage.Favorit.isFavorit : DiaryImage.Favorit.isNotFavorit
        favoritButton.setImage(favoritImage, for: .normal)
        placeName = place.name
        nameLabel.text = place.name
        infoLabel.text = "\(place.group) ∙ \(place.category) ∙ \(place.rating) 점"
        dateLabel.text = place.date.toString
        configureImage(with: place)
    }
    
    private func configureImage(with place: Place) {
        ImageCacheManager.shared.setupImage(with: place.name) { placeImage in
            DispatchQueue.main.async {
                self.placeImageView.image = placeImage
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.image = DiaryImage.placeholer
        placeName = ""
    }
    
    @IBAction private func favoritButtonTapped(_ sender: UIButton) {
        let isFavorit: Bool
        
        if sender.currentImage == DiaryImage.Favorit.isNotFavorit {
            sender.setImage(DiaryImage.Favorit.isNotFavorit, for: .normal)
            isFavorit = true
        } else {
            sender.setImage(DiaryImage.Favorit.isFavorit, for: .normal)
            isFavorit = false
        }
        
        FirestoreManager.shared.updateFavorit(isFavorit, placeName: placeName) { result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                print(failure.errorDescription)
            }
        }
    }
}
