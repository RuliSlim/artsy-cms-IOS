//
//  AddViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var image: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                print("succesProduct", successProduct)
                
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
}
