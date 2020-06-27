//
//  TextField.swift
//  artsy me up cms
//
//  Created by Ruli on 27/06/20.
//

import UIKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialButtons

class CustomTextField {
    static func setTextField(_ textField: MDCFilledTextField, _ title: String, _ tag: Int) -> Void {
        textField.label.text = title
        textField.sizeToFit()
        textField.setUnderlineColor(UIColor.systemPink, for: .editing)
        textField.tag = tag
        textField.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        textField.clearButtonMode = .unlessEditing
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
        switch title {
        case "price", "stock":
            textField.keyboardType = .decimalPad
        case "email":
            textField.autocapitalizationType = .none
            textField.keyboardType = .emailAddress
        case "password":
            textField.autocapitalizationType = .none
            textField.isSecureTextEntry = true
        default:
            break
        }
    }
}
