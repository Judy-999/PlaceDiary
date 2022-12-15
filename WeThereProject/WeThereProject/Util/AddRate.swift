//
//  AddRate.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/07. --> Refacted on 2022/12/15
//

import UIKit

class AddRate{
    var buttonState = [Bool]()
    
    init() {
        for _ in 0...4{
            buttonState.append(false)
        }
    }
    
    func fill(buttons: [UIButton], rate: Float){
        let rateInt = Int(rate)
        fillStar(buttons: buttons, index: rateInt)
       
        if (rate - Float(rateInt)) != 0 {
            buttons[rateInt].setImage(UIImage(systemName: "star.leadinghalf.fill"), for: .normal)
        }
        
        if rate == 0{
            clearStar(buttons: buttons, index: -1)
        }
    }
    
    private func fillStar(buttons: [UIButton], index: Int){
        var i = 0
        while i < index {
            buttons[i].setImage(UIImage(systemName: "star.fill"), for: .normal)
            buttonState[i] = false
            i = i + 1
        }
    }
    
    private func clearStar(buttons: [UIButton], index: Int){
        var i = 4
        while i > index {
            buttons[i].setImage(UIImage(systemName: "star"), for: .normal)
            buttonState[i] = true
            i = i - 1
        }
    }
    
    public func sliderStar(buttons: [UIButton], rate: Float){
        let rateDown = rate.rounded(.down)
        let half = rate - rateDown
        let rateInt = Int(rateDown)
        
        fillStar(buttons: buttons, index: rateInt)
        clearStar(buttons: buttons, index: rateInt)
        
        if half >= 0.5{
            buttons[rateInt].setImage(UIImage(systemName: "star.leadinghalf.fill"), for: .normal)
        }else{
            if rateInt != 5{
                buttons[rateInt].setImage(UIImage(systemName: "star"), for: .normal)}
        }
    }
}
