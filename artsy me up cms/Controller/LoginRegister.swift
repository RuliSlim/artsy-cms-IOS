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
import MaterialComponents.MaterialDialogs

class LoginRegister: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var containerStack: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var layerTop: UIView!
    
    let email: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let password: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let button: MDCButton = MDCButton()
    var customDialog: MDCDialogTransitionController!
    
    var user: User!
    
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
//        email.addTarget(self, action: #selector(checkingEmail), for: UIControlEvents.EditingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                email.leadingAssistiveLabel.textColor = .red
            }
        } else {
            print("ga masuk dong sedih")
        }
    }
    
    @objc func submitLogin(_ sender: Any) {
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.stackView.frame.origin.y == 20 {
                self.stackView.frame.origin.y -= (0.5 * keyboardSize.height)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.stackView.frame.origin.y != 20 {
            self.stackView.frame.origin.y = 20
        }
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
                self.user = data.0
                print(data, "DADATA")
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
                    let alertController = MDCAlertController(title: "Error", message: data.3?.message!)
                    let action = MDCAlertAction(title:"OK") { (action) in print("OK") }
                    alertController.addAction(action)
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
