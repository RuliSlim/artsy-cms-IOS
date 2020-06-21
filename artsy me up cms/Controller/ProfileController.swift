//
//  ProfileController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class ProfileController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        //        entah kenapa ga circular
        print("masuk sini")
        profilePicture.layer.cornerRadius = 20
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.systemPink.cgColor
        profilePicture.layer.borderWidth = 3
    }
}
