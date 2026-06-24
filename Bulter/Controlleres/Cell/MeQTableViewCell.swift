//
//  MeQTableViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit

class MeQTableViewCell: UITableViewCell {

    @IBOutlet weak var meQlabel: UILabel!
    @IBOutlet weak var meQheader: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}
