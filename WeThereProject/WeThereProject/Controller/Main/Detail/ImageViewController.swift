//
//  ImageViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/26. --> Refacted on 2022/12/15
//

import UIKit

final class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var initImgWidth: CGFloat!, initImgHeight: CGFloat!
    var initImgOrigin: CGPoint!
    var fullImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        setImage()
    }
    
    func setImage() {
        imgView.image = fullImage
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}
