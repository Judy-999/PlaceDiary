//
//  CategoryViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/27.
//

import UIKit

protocol categoryDelegate {
    func sendCategory(_ controller: CategoryViewController, category: String)
}

class CategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let PICKER_VIEW_COLUMN = 1
    var category = ["음식점", "카페", "술집", "액티비티", "야외"]
    var selCategory : String?
    var delegate : categoryDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PICKER_VIEW_COLUMN
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selCategory = category[row]
    }
    
    @IBAction func btnSelectCategory(_ sender: UIButton){
        delegate?.sendCategory(self, category: selCategory!)
        _ = navigationController?.popViewController(animated: true)
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
