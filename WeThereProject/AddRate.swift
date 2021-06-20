//
//  AddRate.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/07.
//

import Foundation
import UIKit

class AddRate{
    
    var buttonState = [Bool]()
    
    init() {
        for _ in 0...4{
            buttonState.append(false)
        }
    }
    
    func checkAttr(buttons: [UIButton], button: UIButton) -> Float{
        var i = 0
        while button != buttons[i] {
            i = i + 1
        }
        rateFill(buttons: buttons, index: i)
        
        if buttonState[i] == true {
            return Float(i) + 0.5
        }else{
            return Float(i) + 1.0
        }
    }
    
    private func rateFill(buttons: [UIButton], index: Int){
        if buttonState[index] == false{
            buttons[index].setImage(UIImage(systemName: "star.leadinghalf.fill"), for: .normal)
            buttonState[index] = true
        }
        else{
            buttons[index].setImage(UIImage(systemName: "star.fill"), for: .normal)
            buttonState[index] = false
        }
        fillStar(buttons: buttons, index: index)
        clearStar(buttons: buttons, index: index)
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
}
