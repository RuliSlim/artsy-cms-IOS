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
    
    override func viewDidLoad() {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
                indicator.center = view.center
                view.addSubview(indicator)
                indicator.bringSubviewToFront(view)
//                UIApplication.shared.isNetworkActivityIndicatorVisible = true


        indicator.startAnimating()
//        indicator.stopAnimating()
        super.viewDidLoad()
        //        ganti text back to list
        self.navigationItem.title = "List"
        //        Api Call
        getData { (res) in
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
    
    fileprivate func getData(completion: @escaping (Result<[Product], Error>) -> ()) {
        let baseUrl: String = "https://cms-commerce.herokuapp.com/products"
        guard let url = URL(string: baseUrl) else { return }
        
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

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        
        let product = products[indexPath.row]
        cell.titleItem.text = product.name
        cell.priceItem.text = product.price
        cell.photoItem.load(url: product.image)
        
        cell.photoItem.layer.cornerRadius = cell.photoItem.frame.height / 2
        cell.photoItem.clipsToBounds = true
        cell.photoItem.layer.borderColor = UIColor.systemPink.cgColor
        cell.photoItem.layer.borderWidth = 2
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.item = items[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
