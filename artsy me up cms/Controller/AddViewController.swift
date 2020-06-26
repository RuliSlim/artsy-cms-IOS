//
//  AddViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit
import ImgurAnonymousAPI
import SnapKit

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var image: UITextField!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var viewLabels: UIStackView!
    
//    let name: MDCTextField = {
//      let name = MDCTextField()
//      name.translatesAutoresizingMaskIntoConstraints = false
//      name.autocapitalizationType = .words
//      return name
//    }()
    
    var user: User?
    var product: Product?
    var isEdit: Bool?
    private let imgur = ImgurUploader(clientID: "1b22dd0c6d6e14a")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let editProd = product else { return }
        
//        let nameMDC: MDCTextField = MDCTextField()
////        nameMDC.label.text = "Name of product"
//        viewLabels.addSubview(nameMDC)
        
        
        name.text = editProd.name
        price.text = editProd.price
        stock.text = editProd.price
        image.text = editProd.image.absoluteString
        tempImage.load(url: editProd.image)
        
    }
    
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(tempImage)
        }
        if sender.state == .ended {
            indicator.stopAnimating()
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
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
    }
    
}
