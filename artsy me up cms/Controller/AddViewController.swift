//
//  AddViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit
import FirebaseStorage

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var image: UITextField!
    @IBOutlet weak var tempImage: UIImageView!
    
    var user: User?
    
    private let storage = Storage.storage().reference()
    
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
            case .success(let data):
                let successProduct: Product = data.2!
                
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
        
        guard let url = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
            return
        }
        
        let fileName = url.lastPathComponent
        let fileType = url.pathExtension
        var imageData: Data!
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        switch fileType {
        case "png":
            guard let imageDataTemp = image.pngData() else { return }
            imageData = imageDataTemp
        default:
            guard let imageDataTemp = image.jpegData(compressionQuality: 1) else { return }
            imageData = imageDataTemp
        }

        let location = storage.child("images/\(fileName)") 
        
        location.putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            location.downloadURL { (url, err) in
                guard let url = url, err == nil else { return }
                let urlString = url.absoluteString

                DispatchQueue.main.async {
                    self.tempImage.load(url: URL(string: urlString)!)
                    self.image.text = urlString
                    self.image.isUserInteractionEnabled = false
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
