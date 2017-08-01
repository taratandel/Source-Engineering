//
//  KeyBoardDismiss.swift
//  Managers
//
//  Created by Tara Tandel on 3/31/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
