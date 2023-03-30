//
//  TableViewCell.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/28. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift

final class PlaceCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var favoritButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private var placeName = ""
    
    func configure(with place: Place,
                   _ imageRepository: ImageRepository) {
        placeName = place.name
        nameLabel.text = place.name
        infoLabel.text = "\(place.group) ∙ \(place.category) ∙ \(place.rating) 점"
        dateLabel.text = place.date.toString
        setupFavoritButton(with: place.isFavorit)
        
        imageRepository.load(place.name)
            .bind(to: placeImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func setupFavoritButton(with isFavorit: Bool) {
        let favoritImage = isFavorit ? DiaryImage.Favorit.isFavorit : DiaryImage.Favorit.isNotFavorit
        favoritButton.setImage(favoritImage, for: .normal)
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
        
        //TODO: favorit 변경 firebase에 업데이트
    }
}
