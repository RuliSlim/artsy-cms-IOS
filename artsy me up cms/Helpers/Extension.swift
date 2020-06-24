//
//  Extension.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import Foundation
import UIKit

public extension UIImageView {
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
        detail.product = products[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

//extension UIActivityIndicatorView {
//    func mulai() {
//        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//        indicator.center = view.center
//        view.addSubview(indicator)
//        indicator.bringSubviewToFront(view)
//        indicator.startAnimating()
//    }
//}
