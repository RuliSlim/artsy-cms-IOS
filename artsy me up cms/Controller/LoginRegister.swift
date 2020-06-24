//
//  LoginRegister.swift
//  artsy me up cms
//
//  Created by Ruli on 23/06/20.
//

import UIKit

class LoginRegister: UIViewController {
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func button(_ sender: UIButton) {
//        Loading when submit
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        
        loginAction()
    }
    
    func loginAction() {
        let postString = "email=\(email.text!)&password=\(password.text!)"
        let Login: ApiCall = ApiCall(method: "POST", endPoint: "login", data: postString, type: .user, header: nil)
        Login.getData() { (res) in
            switch res {
            case .success(let data):
                self.user = data.0
                if data.0!.access_token != nil {
                    DispatchQueue.main.async {
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController {
                            
                            if let navigator = self.navigationController {
                                viewController.user = data.0
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                }
            case .failure(let err):
                print("Failed to fetch courses:", err)
            }
        }
    }
}
