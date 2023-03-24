//
//  ImageViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/26. --> Refacted on 2022/12/15
//

import UIKit

final class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    private var fullImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        placeImageView.image = fullImage
    }
    
    func setupImage(with image: UIImage?) {
        fullImage = image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.placeImageView
    }
}
