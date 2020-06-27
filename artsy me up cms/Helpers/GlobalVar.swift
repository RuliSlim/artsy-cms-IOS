//
//  GlobalVar.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialDialogs

let indicator: MDCActivityIndicator = MDCActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
let alertController = MDCAlertController(title: "Error", message: "")
let action = MDCAlertAction(title:"OK") { (action) in print("OK") }
