//
//  UIViewController+.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/13.
//

import UIKit

extension UIViewController {
    func showAlert(_ alertCase: Alert) {
        let alert = UIAlertController(title: alertCase.title,
                                      message: alertCase.message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String?, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
