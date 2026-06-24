//
//  ChuangDetailsItemsCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/11.
//

import UIKit

class ChuangDetailsItemsCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }

}
