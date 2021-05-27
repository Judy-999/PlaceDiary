//
//  AddPlaceViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/27.
//

import UIKit
import MobileCoreServices

class AddPlaceViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tfPlaceName: UITextField!
    @IBOutlet var btnPhoto: UIButton!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  placeImageView.image = UIImage(named: "example.jpeg")   //임시
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnAddPlace(_ sender: UIButton){
        placeTitles.append(tfPlaceName.text!)
        placeImages.append(selectedImage)  //임시
        tfPlaceName.placeholder = "이름을 입력하세요."
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func btnPhoto(_ sender: UIButton){
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
        }else{
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage //사진을 가져와 라이브러리에 저장

        placeImageView.image = selectedImage
        self.dismiss(animated: true, completion: nil)   //현재 뷰 컨트롤러 제거
    }
    
    //사용자가 사진이나 비디오를 찍지 않고 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)   //이미지 피커를 제거하고 초기 뷰를 보여줌
    }
    
    
    //경고 표시
    func myAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
