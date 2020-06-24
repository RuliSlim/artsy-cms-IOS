//
//  AddViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit
import ImgurAnonymousAPI

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var image: UITextField!
    @IBOutlet weak var tempImage: UIImageView!
    
    var user: User?
    private let imgur = ImgurUploader(clientID: "1b22dd0c6d6e14a")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        indicator.startAnimating()
        let postString = "name=\(name.text!)&price=\(price.text!)&stock=\(stock.text!)&image=\(image.text!)"
        let submit: ApiCall = ApiCall(method: "POST", endPoint: "products", data: postString, type: .product, header: self.user?.access_token!)
        
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        
        submit.getData { (res) in
            switch res {
            case .success(_):
                DispatchQueue.main.async {
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController {
                        if let navigator = self.navigationController {
                            indicator.stopAnimating()
                            viewController.user = self.user
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }
                
            case .failure(let err):
                print("error", err)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
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
