//
//  Extension.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

extension HomePageVC: UITableViewDataSource {
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

extension HomePageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.product = products[indexPath.row]
        detail.user = self.user
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
