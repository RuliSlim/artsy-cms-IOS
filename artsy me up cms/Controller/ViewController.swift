//
//  ViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        ganti text back to list
        self.navigationItem.title = "List"
        //        get items
//        ItemTableViewCell.dataSource = self
        itemTableView.dataSource = self
        itemTableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemCell")

    }
    
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Digunakan untuh menghubungkan cell dengan identifier "HeroCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        
        // Menetapkan nilai hero ke view di dalam cell
        let item = items[indexPath.row]
        cell.titleItem.text = item.title
        cell.priceItem.text = String(item.price)
        cell.photoItem.image = item.photo
        
        // Kode ini digunakan untuk membuat imageView memiliki frame bound/lingkaran
        cell.photoItem.layer.cornerRadius = cell.photoItem.frame.height / 2
        cell.photoItem.clipsToBounds = true
        return cell
    }
}
