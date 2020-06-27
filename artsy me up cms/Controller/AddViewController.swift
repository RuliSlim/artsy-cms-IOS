//
//  AddViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit
import ImgurAnonymousAPI
import SnapKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialButtons

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var viewLabels: UIStackView!
    
    var user: User?
    var product: Product?
    var isEdit: Bool?
    private let imgur = ImgurUploader(clientID: "1b22dd0c6d6e14a")
//    var authKeyboardHandler = AuthKeyboardHandler()
    var activeTextField = UITextField()
    
    let name: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let price: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let stock: MDCFilledTextField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let image: MDCFilledTextField = MDCFilledTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabels()
        print(view.frame.origin.y, "ini loc")
        guard let editProd = product else { return }
        
        name.text = editProd.name
        price.text = editProd.price
        stock.text = editProd.price
        image.text = editProd.image.absoluteString
        tempImage.load(url: editProd.image)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        isActive()
//        textFieldDidBeginEditing(_ textField: UITextField)
        
//        name.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        name.addTarget(self, action: #selector(isEditingNow), for: UIControl.Event.editingChanged)
//        name.addTarget(self, action: #selector(isEditingNow), for: UIControl.Event.editingChanged)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print(view.frame.origin.y)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0.0 {
                print("masuk ga sih")
                self.view.frame.origin.y -= (0.5 * keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        print(view.frame.origin.y)
        if self.view.frame.origin.y != 0.0 {
            self.view.frame.origin.y = 0.0
        }
    }
    
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        indicator.startAnimating()
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(tempImage)
        }
        if sender.state == .ended {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        
        if name.text == "" {
            alertController.message = "nama produk tidak boleh kosong!"
            present(alertController, animated: true, completion: nil)
            return
        }
        if image.text == "" {
            alertController.message = "tolong upload photo produk"
            present(alertController, animated: true, completion: nil)
            return
        }
        if price.text == "" {
            alertController.message = "masukan harga barang"
            present(alertController, animated: true, completion: nil)
            return
        }
        if stock.text == "" {
            alertController.message = "masukan stok produk"
            present(alertController, animated: true, completion: nil)
            return
        }
        
        indicator.startAnimating()
        
        let uploadProduct: UploadProduct = UploadProduct(name: name.text!, image: image.text!, price: Int(price.text!)!, stock: Int(stock.text!)!)
        
        var submit: ApiCall!
        
        if product != nil {
            submit = ApiCall(method: "PUT", endPoint: "products/\(product!.id)", data: (nil, uploadProduct), type: .edit, header: self.user?.access_token!)
        } else {
            submit = ApiCall(method: "POST", endPoint: "products", data: (nil, uploadProduct), type: .product, header: self.user?.access_token!)
        }
        
        submit.getData { (res) in
            switch res {
            case .success(_):
                DispatchQueue.main.async {
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController
                    indicator.stopAnimating()
                    guard viewController != nil else { return }
                    viewController?.user = self.user
                    self.navigationController?.pushViewController(viewController!, animated: true)
                }
            case .failure(let err):
                print("error di edit", err)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        indicator.startAnimating()
        
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(tempImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        imgur.upload(info, completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    self.image.text = response.link.absoluteString
                    self.image.isUserInteractionEnabled = false
                    self.tempImage.load(url: response.link)
                }
            case .failure(let error):
                print("Upload failed: \(error)")
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        indicator.stopAnimating()
    }
    
    func setLabels() -> Void {
        viewLabels.addArrangedSubview(name)
        viewLabels.addArrangedSubview(price)
        viewLabels.addArrangedSubview(stock)
        viewLabels.alignment = .fill
        viewLabels.distribution = .fillEqually
        viewLabels.spacing = 5
        setTextFields()
    }
    
    func setTextFields() -> Void {
        name.label.text = "name"
        name.autocapitalizationType = .words
        name.sizeToFit()
        name.setUnderlineColor(UIColor.systemPink, for: .editing)
        //        name.delegate = self
        name.tag = 0
        name.keyboardType = .alphabet
        name.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        name.clearButtonMode = .unlessEditing
        
        price.label.text = "price"
        price.sizeToFit()
        price.setUnderlineColor(UIColor.systemPink, for: .editing)
        price.tag = 1
        price.keyboardType = .decimalPad
        price.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        price.clearButtonMode = .unlessEditing
        
        stock.label.text = "stock"
        stock.sizeToFit()
        stock.setUnderlineColor(UIColor.systemPink, for: .editing)
        stock.tag = 2
        stock.keyboardType = .numberPad
        name.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        name.clearButtonMode = .unlessEditing
    }
    
    // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("masuk sini sih?", view.frame.origin, "NIH KOOR NYA")
         self.activeTextField = textField
    }
    
    func isActive() {
        print(name.isEditing, "iya ga cuuuy>S>F>S>?")
    }
    
    @objc func isEditingNow(_ sender: Any) {
        print("YAAAAY MASUK SINI CUUUUK")
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print("masuk sini ga cuy?", view.frame.origin, "Nih asdsadsadsds")
//        self.activeTextField = textField
//    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCFilledTextField {
//            nextField.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//            submitLogin(self)
//        }
//        return false
//    }

    // Call activeTextField whenever you need to
    func anotherMethod() {
        print("eh masuknya ke siinini cuk")
        // self.activeTextField.text is an optional, we safely unwrap it here
        if let activeTextFieldText = self.activeTextField.text {
              print("Active text field's text: \(activeTextFieldText)")
              return;
        }

        print("Active text field is empty")
    }
}
