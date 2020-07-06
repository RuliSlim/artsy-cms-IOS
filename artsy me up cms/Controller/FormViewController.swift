//
//  FormViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 27/06/20.
//

import UIKit
import SnapKit
import ImgurAnonymousAPI

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialButtons

class FormViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var container: UIView!
    
    private let imgur = ImgurUploader(clientID: "1b22dd0c6d6e14a")

    var user: User!
    var product: Product?
    var isEdit: Bool?
    var submit: ApiCall!
    
    //    MDC
    let name: MDCFilledTextField = MDCFilledTextField()
    let price: MDCFilledTextField = MDCFilledTextField()
    let stock: MDCFilledTextField = MDCFilledTextField()
    let image: MDCFilledTextField = MDCFilledTextField()
    let button: MDCButton = MDCButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStack()
        name.delegate = self
        price.delegate = self
        stock.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        guard product != nil else { return }
        name.text = product!.name
        price.text = String(product!.price)
        stock.text = String(product!.stock)
        image.text = product!.image.absoluteString
        showImage.load(url: product!.image)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.bindToKeyboard()
    }
    
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        view.addSubview(indicator)
        showImage.isHidden = true
        indicator.bringSubviewToFront(view)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(showImage)
        }
        indicator.startAnimating()
        if sender.state == .ended {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)            
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        indicator.startAnimating()
        
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(showImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        imgur.upload(info, completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    self.showImage.isHidden = false
                    self.image.text = response.link.absoluteString
                    self.showImage.load(url: response.link)
                }
            case .failure(let error):
                print("Upload failed: \(error)")
            }
        })
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        indicator.stopAnimating()
        showImage.isHidden = false
    }
    
    @objc func submitButton(_ sender: Any) {
        if let isEmpty = Validation.isNotEmpty(senders: [name, price, stock, image]) {
            alertController.message = isEmpty + "produk tidak boleh kosong"
            alertController.addAction(action)
            present(alertController, animated: true)
            return
        }
        if let notInt = Validation.checkingInt(senders: [price, stock]) {
            alertController.message = notInt + "produk harus dalam angka"
            alertController.addAction(action)
            present(alertController, animated: true)
            return
        }
        
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        indicator.startAnimating()
        
        let uploadProduct: UploadProduct = UploadProduct(name: name.text!, image: image.text!, price: Int(price.text!)!, stock: Int(stock.text!)!)
        
        if product != nil {
            submit = ApiCall(method: "PUT", endPoint: "products/\(product!.id)", data: (nil, uploadProduct), type: .edit, header: user?.access_token!)
        } else {
            submit = ApiCall(method: "POST", endPoint: "products", data: (nil, uploadProduct), type: .product, header: user?.access_token!)
        }
        
        submit.getData { (res) in
            switch res {
            case .success(_):
                DispatchQueue.main.async {
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? HomePageVC
                    indicator.stopAnimating()
                    guard viewController != nil else { return }
                    viewController?.user = self.user
                    self.navigationController?.pushViewController(viewController!, animated: true)
                }
            case .failure(let err):
                print(err, "error di form prod")
            }
        }
    }
    
    private func setStack() -> Void {
        CustomTextField.setTextField(name, "name", 0)
        CustomTextField.setTextField(price, "price", 1)
        CustomTextField.setTextField(stock, "stock", 2)
        CustomTextField.setTextField(image, "photo", 0)
        name.delegate = self
        price.delegate = self
        stock.delegate = self
        
        button.setTitle("Submit", for: UIControl.State())
        button.backgroundColor = .systemPink
        button.titleLabel?.textColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(submitButton(_:)), for: .touchDown)
        
        container.addSubview(name)
        container.addSubview(price)
        container.addSubview(stock)
        container.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.bottom.equalTo(container).offset(-20)
            make.leading.equalTo(container).offset(20)
            make.trailing.equalTo(container).offset(-20)
        }
        stock.snp.makeConstraints { (make) in
            make.bottom.equalTo(button).offset(-20 - button.frame.size.height)
            make.leading.equalTo(container).offset(20)
            make.trailing.equalTo(container).offset(-20)
        }
        price.snp.makeConstraints { (make) in
            make.bottom.equalTo(stock).offset(-20 - button.frame.size.height)
            make.leading.equalTo(container).offset(20)
            make.trailing.equalTo(container).offset(-20)
        }
        name.snp.makeConstraints { (make) in
            make.bottom.equalTo(price).offset(-20 - price.frame.size.height)
            make.leading.equalTo(container).offset(20)
            make.trailing.equalTo(container).offset(-20)
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCFilledTextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            submitButton(self)
        }
        return false
    }
}
