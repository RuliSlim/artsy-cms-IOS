//
//  DetailViewController.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit
import SnapKit
import MaterialComponents.MaterialButtons

class DetailViewController: UIViewController {
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemStock: UILabel!
    @IBOutlet weak var itemDesc: UILabel!
    
    var product: Product?
    var user: User!
    var editButton: MDCButton = MDCButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = product {
            itemTitle.text = result.name
            itemPrice.text = String(result.price)
            itemStock.text = String(result.stock)
            itemDesc.text = result.createdAt
            itemPhoto.load(url: result.image)
        }
        
        editButton.setTitle("Edit", for: UIControl.State())
        editButton.backgroundColor = .systemPink
        editButton.titleLabel?.textColor = .black
        editButton.sizeToFit()
        
        view.addSubview(editButton)
        editButton.bringSubviewToFront(view)
        
        editButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(30)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
        }
        
        editButton.addTarget(self, action: #selector(toEditPage), for: .touchDown)
    }
    
    @objc func toEditPage(_ sender: UIButton) {
        let editPage = FormViewController(nibName: "FormViewController", bundle: nil)
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
                    let homePage = board.instantiateViewController(withIdentifier: "list") as! HomePageVC
                    homePage.user = self.user
                    self.navigationController?.pushViewController(homePage, animated: true)
                }
            case .failure(let err):
                print(err)
            }
        }
    }
}
