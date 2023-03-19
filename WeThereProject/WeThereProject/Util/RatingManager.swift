//
//  AddRate.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/07. --> Refacted on 2022/12/15
//

import UIKit

final class RatingManager {
    @discardableResult
    func sliderStar(_ buttons: [UIButton], rating: Float) -> String {
        var ratingValue = rating.rounded(.down)
        let halfRating = rating - ratingValue
        let rateIndex = Int(ratingValue)

        clearStar(buttons)
        fillStar(buttons, to: rateIndex)

        if halfRating >= Rating.halfValue {
            buttons[rateIndex].setImage(Rating.halfStarImage, for: .normal)
            ratingValue += Rating.halfValue
        }
        
        return String(format: "%.1f", ratingValue)
    }
    
    private func fillStar(_ buttons: [UIButton], to index: Int) {
        for fillIndex in Int.zero..<index {
            buttons[fillIndex].setImage(Rating.fillStarImage, for: .normal)
        }
    }
    
    private func clearStar(_ buttons: [UIButton]) {
        buttons.forEach {
            $0.setImage(Rating.emptyStarImage, for: .normal)
        }
    }
}


fileprivate enum Rating {
    static let halfStarImage = UIImage(systemName: "star.leadinghalf.fill")
    static let emptyStarImage = UIImage(systemName: "star")
    static let fillStarImage = UIImage(systemName: "star.fill")
    static let halfValue: Float = 0.5
}
