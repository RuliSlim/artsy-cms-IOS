//
//  DetailViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemStock: UILabel!
    @IBOutlet weak var itemDesc: UILabel!
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = item {
            itemTitle.text = result.title
            itemPrice.text = String(result.price)
            itemStock.text = String(result.price)
            itemDesc.text = result.description
            itemPhoto.image = result.photo
        }
    }
    
}
