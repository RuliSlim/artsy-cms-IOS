//
//  ViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //        let navbar = UINavigationBarAppearance()
        //        navbar.shadowColor = .clear
        //        print(navbar)
        let backBarButtton = UIBarButtonItem(title: "List", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
        print(UINavigationBarAppearance.init())
    }


}

