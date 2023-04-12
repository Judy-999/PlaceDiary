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
    private var imageRepository: ImageRepository?
    private var placeRepository: PlaceRepository?
    private var place: Place?
    
    func configure(with place: Place,
                   _ imageRepository: ImageRepository,
                   _ placeRepository: PlaceRepository) {
        self.place = place
        self.imageRepository = imageRepository
        self.placeRepository = placeRepository
        
        nameLabel.text = place.name
        infoLabel.text = "\(place.group) ∙ \(place.category) ∙ \(place.rating) 점"
        dateLabel.text = place.date.toString
        setupFavoritButton(with: place.isFavorit)
        loadImage(with: place.name)
    }
    
    private func loadImage(with name: String) {
        imageRepository?.load(name)
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
    }
    
    @IBAction private func favoritButtonTapped(_ sender: UIButton) {
        guard var place = place else { return }

        place.isFavorit = sender.currentImage == DiaryImage.Favorit.isNotFavorit
        
        placeRepository?.savePlace(place)
            .subscribe(onCompleted: {
                DispatchQueue.main.async {
                    self.setupFavoritButton(with: place.isFavorit)
                }
            })
            .disposed(by: disposeBag)
    }
}
