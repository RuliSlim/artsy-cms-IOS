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

class FormViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var stackLabel: UIStackView!
    
    private let imgur = ImgurUploader(clientID: "1b22dd0c6d6e14a")
    var authKeyboard: AuthKeyboardHandler = AuthKeyboardHandler()
    var user: User!
    var product: Product?
    var isEdit: Bool?
    var submit: ApiCall!
    
    //    MDC
    let name: MDCFilledTextField = MDCFilledTextField()
    let price: MDCFilledTextField = MDCFilledTextField()
    let stock: MDCFilledTextField = MDCFilledTextField()
    let image: MDCFilledTextField = MDCFilledTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStack()
        authKeyboard.view = view
        authKeyboard.notificationCenterHandler()
        
        guard product != nil else { return }
        name.text = product!.name
        price.text = String(product!.price)
        stock.text = String(product!.stock)
        image.text = product!.image.absoluteString
        showImage.load(url: product!.image)
    }
    
    @IBAction func submitButton(_ sender: Any) {
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
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        indicator.stopAnimating()
        showImage.isHidden = false
    }
    
    func setStack() -> Void {
        setTextField(name, "name", 0)
        setTextField(price, "price", 1)
        setTextField(stock, "stock", 2)
        setTextField(image, "photo", 0)
        
        stackLabel.addArrangedSubview(name)
        stackLabel.addArrangedSubview(price)
        stackLabel.addArrangedSubview(stock)
        
        name.snp.makeConstraints { (make) in
            make.width.equalTo(stackLabel)
        }
        price.snp.makeConstraints { (make) in
            make.width.equalTo(stackLabel)
        }
        stock.snp.makeConstraints { (make) in
            make.width.equalTo(stackLabel)
        }
        
        stackLabel.alignment = .fill
        stackLabel.distribution = .fillEqually
    }
    
    func setTextField(_ textField: MDCFilledTextField, _ title: String, _ tag: Int) -> Void {
        textField.label.text = title
        textField.sizeToFit()
        textField.setUnderlineColor(UIColor.systemPink, for: .editing)
        textField.tag = tag
        textField.frame = CGRect(x: 30, y: 20, width: 20, height: 30)
        textField.clearButtonMode = .unlessEditing
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCFilledTextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            submitButton(self)
        }
        return false
    }
}
