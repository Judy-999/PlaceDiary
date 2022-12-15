//
//  TagTextView.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/10. --> Refacted on 2022/12/15
//

import UIKit

class TagTextView: UITextView {
    var tagArr: [String]?
    
    func makeTag(){
        self.isEditable = false
        self.isSelectable = true
        
        let tagText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string : tagText as String)
        let tagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let result = tagDetector?.matches(in: self.text, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.text.utf16.count))
        
        tagArr = result?.map{ (self.text as NSString).substring(with: $0.range(at: 1))}
        
        if tagArr?.count != 0{
            var i = 0
            for var word in tagArr!{
                word = "#" + word
                if word.hasPrefix("#"){
                    let matchRange: NSRange = tagText.range(of: word, options: [.caseInsensitive, .backwards])
                    
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    i = i + 1
                }
            }
        }
        self.attributedText = attrString
    }
}
