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
    
    var product: Product?
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = product {
            itemTitle.text = result.name
            itemPrice.text = String(result.price)
            itemStock.text = String(result.stock)
            itemDesc.text = result.createdAt
            itemPhoto.load(url: result.image)
        }
    }
    
    @IBAction func toEditPage(_ sender: UIButton) {
        let editPage = AddViewController(nibName: "AddViewController", bundle: nil)
        editPage.user = user
        editPage.product = product
        self.navigationController?.pushViewController(editPage, animated: true)
    }
    
    @IBAction func deleteProd(_ sender: UIButton) {
        let api: ApiCall = ApiCall(method: "DELETE", endPoint: "products/\(product!.id)", data: nil, type: .edit, header: user.access_token!)
        
        api.getData { (res) in
            switch res {
            case .success(_):
                DispatchQueue.main.async {
                    let board = UIStoryboard(name: "Main", bundle: nil)
                    let homePage = board.instantiateViewController(withIdentifier: "list") as! ViewController
                    homePage.user = self.user
                    self.navigationController?.pushViewController(homePage, animated: true)
                }
            case .failure(let err):
                print(err)
            }
        }
    }
}
