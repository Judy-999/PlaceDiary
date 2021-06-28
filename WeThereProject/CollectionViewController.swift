//
//  CollectionViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/27.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var test: GroupInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        test = GroupInfo(name: "cafe")
        cell.updateCell(test!)
        return cell
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
