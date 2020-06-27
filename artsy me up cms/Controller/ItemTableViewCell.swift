//
//  ItemTableViewCell.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var photoItem: UIImageView!
    @IBOutlet weak var titleItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
