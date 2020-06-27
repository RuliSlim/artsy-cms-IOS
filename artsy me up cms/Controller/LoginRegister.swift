//
//  LoginRegister.swift
//  artsy me up cms
//
//  Created by Ruli on 23/06/20.
//

import UIKit
import SnapKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialButtons

class LoginRegister: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var containerStack: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var layerTop: UIView!
    
    let email: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let password: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let button: MDCButton = MDCButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        email.label.text = "email"
        email.autocapitalizationType = .none
        email.sizeToFit()
        email.setUnderlineColor(UIColor.systemPink, for: .editing)
        email.delegate = self
        email.tag = 0
        email.keyboardType = .emailAddress
        email.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        email.clearButtonMode = .unlessEditing
        
        password.label.text = "password"
        password.autocapitalizationType = .none
        password.sizeToFit()
        password.setUnderlineColor(.systemPink, for: .editing)
        password.delegate = self
        password.tag = 1
        password.isSecureTextEntry = true
        password.frame = CGRect(x: 30, y:20, width: 20, height: 30)
        password.clearButtonMode = .unlessEditing
        
        button.setTitle("Login", for: UIControl.State())
        button.backgroundColor = .systemPink
        button.titleLabel?.textColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(submitLogin(_:)), for: .touchDown)
        
        stackView.addArrangedSubview(email)
        stackView.addArrangedSubview(password)
        stackView.addArrangedSubview(button)
        
        email.snp.makeConstraints { (make) in
            make.width.equalTo(stackView)
        }
        password.snp.makeConstraints { (make) in
            make.width.equalTo(stackView)
        }
        button.snp.makeConstraints { (make) in
            make.width.equalTo(stackView)
        }
        
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        
        email.addTarget(self, action: #selector(checkingEmail), for: UIControl.Event.editingChanged)
        password.addTarget(self, action: #selector(checkingEmail), for: UIControl.Event.editingChanged)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func tapToView(_ sender: UITapGestureRecognizer) {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    @objc func checkingEmail(_ sender: Any) {
        if sender as! NSObject == self.email {
            let status = Validation.checkingEmail(sender: self.email)
            if status {
                email.leadingAssistiveLabel.text = ""
            } else {
                email.leadingAssistiveLabel.text = "please input valid email address"
                email.leadingAssistiveLabel.textColor = UIColor.red
            }
        }
    }
    
    @objc func submitLogin(_ sender: Any) {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.sizeToFit()
        
        layerTop.isHidden = false
        
        email.resignFirstResponder()
        password.resignFirstResponder()
        indicator.startAnimating()
        
        loginAction()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCFilledTextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            submitLogin(self)
        }
        return false
    }
    
    func loginAction() {
        let loginData: Login = Login(email: email.text!, password: password.text!)
        let Login: ApiCall = ApiCall(method: "POST", endPoint: "login", data: (loginData, nil), type: .user, header: nil)
        Login.getData() { (res) in
            switch res {
            case .success(let data):
                if data.0?.access_token != nil {
                    DispatchQueue.main.async {
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController {
                            if let navigator = self.navigationController {
                                viewController.user = data.0
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                } else {
                    alertController.addAction(action)
                    alertController.message = data.3?.message!
                    DispatchQueue.main.async {
                        self.layerTop.isHidden = true
                        self.present(alertController, animated:true, completion: nil)
                        indicator.stopAnimating()
                    }
                }
            case .failure(let err):
                self.layerTop.isHidden = true
                print("Failed to fetch courses:", err)
            }
        }
    }
}
