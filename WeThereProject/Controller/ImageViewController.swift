//
//  ImageViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/26.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

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
    

    func setImage(){
        imgView.image = fullImage
    }
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch   //발생한 터치 이벤트 받아오기
        
        print(String(touch.tapCount))
        
        if touch.tapCount == 2{
            imgView.frame.origin = initImgOrigin
            imgView.frame.size = CGSize(width: initImgWidth, height: initImgHeight)
            imgView.image = fullImage
           // imgView.transform = imgView.transform.scaledBy(x: 1, y: 1)
            print("여긴 들어오니")
            
        }
    }
    */
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    /*
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer){
        imgView.transform = imgView.transform.scaledBy(x: pinch.scale, y: pinch.scale)  //이미지를 scale에 맞게 변경
        pinch.scale = 1 //다음 변환을 위해 핀치 스케일 초기화
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
