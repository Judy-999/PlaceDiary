//
//  SettingViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import FirebaseStorage

class SettingViewController: UIViewController {

    @IBOutlet var testImg: UIImageView!
    
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        downloadImage()
       // down()
    }
    
    func downloadImage(){
        let fileUrl = "gs://wethere-2935d.appspot.com"
        storage.reference(forURL: fileUrl).downloadURL { url, error in
            let data = NSData(contentsOf: url!)
            let downloadImg = UIImage(data: data! as Data)
            self.testImg.image = downloadImg
        }
    }
    
    func down(){
        let islandRef = Storage.storage().reference().child("콤마")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
            self.testImg.image = UIImage(data: data!)
          }
        }
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
