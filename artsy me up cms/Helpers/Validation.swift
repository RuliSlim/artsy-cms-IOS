//
//  Validation.swift
//  artsy me up cms
//
//  Created by Ruli on 26/06/20.
//

import Foundation
import UIKit

class Validation {
    static func checkingEmail(sender: UITextField) -> Bool {
        let emailID = sender.text!
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
        let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValidateEmail = validateEmail.evaluate(with: trimmedString)
        return isValidateEmail
    }
}
