//
//  AddRate.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/07. --> Refacted on 2022/12/15
//

import UIKit

final class RatingManager {
    @discardableResult
    func sliderStar(_ imageView: [UIImageView], rating: Float) -> String {
        var ratingValue = rating.rounded(.down)
        let halfRating = rating - ratingValue
        let rateIndex = Int(ratingValue)

        clearStar(imageView)
        fillStar(imageView, to: rateIndex)

        if halfRating >= Rating.halfValue {
            imageView[rateIndex].image = Rating.halfStarImage
            ratingValue += Rating.halfValue
        }
        
        return String(format: "%.1f", ratingValue)
    }
    
    private func fillStar(_ imageVeiws: [UIImageView], to index: Int) {
        for fillIndex in Int.zero..<index {
            imageVeiws[fillIndex].image = Rating.fillStarImage
        }
    }
    
    private func clearStar(_ imageVeiws: [UIImageView]) {
        imageVeiws.forEach {
            $0.image = Rating.emptyStarImage
        }
    }
}


fileprivate enum Rating {
    static let halfStarImage = UIImage(systemName: "star.leadinghalf.fill")
    static let emptyStarImage = UIImage(systemName: "star")
    static let fillStarImage = UIImage(systemName: "star.fill")
    static let halfValue: Float = 0.5
}
