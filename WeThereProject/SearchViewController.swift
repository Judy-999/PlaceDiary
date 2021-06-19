//
//  SearchViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
          let controller = GMSAutocompleteViewController() //구글 자동완성 뷰컨트롤러 생성
          controller.delegate = self //딜리게이트
          present(controller, animated: true, completion: nil) //보여주기
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

extension SearchViewController: GMSAutocompleteViewControllerDelegate { //해당 뷰컨트롤러를 익스텐션으로 딜리게이트를 달아준다.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
         print("Place name: \(String(describing: place.name))") //셀탭한 글씨출력
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place latitude: \(String(describing: place.coordinate.latitude))")
        print("Place longitude: \(String(describing: place.coordinate.longitude))")
        dismiss(animated: true, completion: nil) //화면꺼지게
    } //원하는 셀 탭했을 때 꺼지게
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)//에러났을 때 출력
    } //실패했을 때
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil) //화면 꺼지게
    } //캔슬버튼 눌렀을 때 화면 꺼지게
    
}
