//
//  CoinTableViewCell.swift
//  UAS_C14190016
//
//  Created by IOS on 15/06/22.
//

import UIKit

class CoinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinView: UIStackView!
    
    @IBOutlet weak var coinImageView: UIImageView!
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usdLabel: UILabel!
    
    @IBOutlet weak var idrLabel: UILabel!
    
    @IBOutlet weak var exchangeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
