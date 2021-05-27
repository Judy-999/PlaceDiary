//
//  PlaceInfoViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/27.
//

import UIKit

class PlaceInfoViewController: UIViewController {

    var receiceName = ""
    var receiveImage: UIImage?
    var receiveSub = ""
    
    @IBOutlet var txtPlacename: UILabel!
    @IBOutlet var txtPlaceSub: UILabel!
    @IBOutlet var placeImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtPlacename.text = receiceName
        txtPlaceSub.text = receiveSub
        placeImg.image = receiveImage
    }
    
    func recievePlace(_ name: String, subname: String, image: UIImage){
        receiceName = name
        receiveSub = subname
        receiveImage = image
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
