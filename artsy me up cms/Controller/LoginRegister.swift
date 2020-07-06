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
        
        // setings custom elements
        setElements()
        
        // move when keyboard showed up
        stackView.bindToKeyboard()
        
        email.addTarget(self, action: #selector(checkingEmail), for: UIControl.Event.editingChanged)
        password.addTarget(self, action: #selector(checkingEmail), for: UIControl.Event.editingChanged)
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
                email.setLeadingAssistiveLabelColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), for: .editing)
                email.setLeadingAssistiveLabelColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                email.leadingAssistiveLabel.text = "please input valid email address"
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
    
    private func setElements() {
        CustomTextField.setTextField(email, "email", 0)
        CustomTextField.setTextField(password, "password", 1)
        
        email.delegate = self
        password.delegate = self
        
        button.setTitle("Login", for: UIControl.State())
        button.backgroundColor = .systemPink
        button.titleLabel?.textColor = .black
        button.sizeToFit()
        button.frame.size.width = 50
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
        stackView.spacing = 10
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCFilledTextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            submitLogin(self)
        }
        return false
    }
    
    private func loginAction() {
        let loginData: Login = Login(email: email.text!, password: password.text!)
        let Login: ApiCall = ApiCall(method: "POST", endPoint: "login", data: (loginData, nil), type: .user, header: nil)
        Login.getData() { (res) in
            switch res {
            case .success(let data):
                if data.0?.access_token != nil {
                    DispatchQueue.main.async {
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? HomePageVC {
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
            case .failure(_):
                alertController.addAction(action)
                alertController.message = "Failed to fetch"
                DispatchQueue.main.async {
                    self.layerTop.isHidden = true
                    self.present(alertController, animated: true, completion: nil)
                    indicator.stopAnimating()
                }
            }
        }
    }
}
