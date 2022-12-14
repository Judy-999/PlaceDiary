//
//  TagTextView.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/10.
//

import Foundation
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

/*
// 한글, 영문, 숫자만 가능
class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    
    func resolveHashTags() {
        self.isEditable = false
        self.isSelectable = true
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))

        hashtagArr = results?.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
                                
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: .caseInsensitive)
                                                                
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
}
*/
