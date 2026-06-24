//
//  ElevtCollectionViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/12.
//

import UIKit

class ElevtCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var rmblabel: UILabel!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 13
        layer.masksToBounds = true
        
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
    }

}
