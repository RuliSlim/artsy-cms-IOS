//
//  ViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var itemTableView: UITableView!
    
    var products: [Product] = []
    var user: User?
    var api: ApiCall = ApiCall()
    
    override func viewDidLoad() {
        //        navigationController?.popViewController(animated: true)
        //        api.get
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        
        indicator.startAnimating()
        super.viewDidLoad()
        //        ganti text back to list
        self.navigationItem.title = "List"
        //        Api Call
        api.getData(method: "GET", endPoint: "products") { (res) in
            switch res {
            case .success(let data):
                DispatchQueue.main.async {
                    self.products = data
                    self.itemTableView.reloadData()
                    indicator.stopAnimating()
                }
            case .failure(let err):
                print("Failed to fetch courses:", err)
            }
        }
        
        //        table items
        itemTableView.dataSource = self
        //        connect to detail controller
        itemTableView.delegate = self
        itemTableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
    }
    
    fileprivate func getData(method: String, endPoint: String, completion: @escaping (Result<[Product], Error>) -> ()) {
        let baseUrl: String = "https://cms-commerce.herokuapp.com/"
        guard let url = URL(string: baseUrl + endPoint) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            //            succes
            do {
                let products: [Product] = try JSONDecoder().decode([Product].self, from: data!)
                completion(.success(products))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }
        .resume()
    }
}
