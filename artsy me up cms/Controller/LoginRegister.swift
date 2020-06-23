//
//  LoginRegister.swift
//  artsy me up cms
//
//  Created by Ruli on 23/06/20.
//

import UIKit

class LoginRegister: UIViewController {
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func button(_ sender: Any) {
        print(email.text!, "ema")
        print(password.text!, "password")
        login(method: "POST", endPoint: "login") { (res) in
            switch res {
            case .success(let data):
                print(data, "ini data")
                self.user = data
                if data.access_token != nil {
                    DispatchQueue.main.async {
                        print("masuk sini")

                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as? ViewController {

                            if let navigator = self.navigationController {
                                viewController.user = data
//                                navigator.present(viewController, animated: true, completion: nil)
//                                navigator.popViewController(animated: true)
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                }
            case .failure(let err):
                print("Failed to fetch courses:", err)
            }
        }
    }
    
    fileprivate func login(method: String, endPoint: String, completion: @escaping (Result<User, Error>) -> ()) {
        let baseUrl: String = "https://cms-commerce.herokuapp.com/"
        guard let url = URL(string: baseUrl + endPoint) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        let postString = "email=\(email.text!)&password=\(password.text!)"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            //            succes
            do {
                let user: User = try JSONDecoder().decode(User.self, from: data!)
                completion(.success(user))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }
        .resume()
    }
}
