//
//  ImageViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/26.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    
    var fullImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
        setImage()
    }
    

    func setImage(){
        imgView.image = fullImage
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer){
        imgView.transform = imgView.transform.scaledBy(x: pinch.scale, y: pinch.scale)  //이미지를 scale에 맞게 변경
        pinch.scale = 1 //다음 변환을 위해 핀치 스케일 초기화
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
