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
    let api: ApiCall = ApiCall(method: "GET", endPoint: "products", data: nil, type: .products, header: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)

        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        
        //        ganti text back to list
        self.navigationItem.title = "List"
        self.navigationItem.titleView = UIView()
        
        //        Api Call
        api.getData() { (res) in
            switch res {
            case .success(let data):
                DispatchQueue.main.async {
                    self.products = data.1!
                    self.itemTableView.reloadData()
                    //                    Loading Stop
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
    
    @IBAction func goToAdd(_ sender: Any) {
        let addProduct = AddViewController(nibName: "AddViewController", bundle: nil)
        addProduct.user = self.user
        self.navigationController?.pushViewController(addProduct, animated: true)
    }
}
