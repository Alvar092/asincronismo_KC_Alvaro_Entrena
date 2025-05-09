//
//  HeroTableViewCell.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 9/5/25.
//

import UIKit

class HeroTableViewCell: UITableViewCell {

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroTitleText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
