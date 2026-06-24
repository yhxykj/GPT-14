//
//  YuYinClassCollectionCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/2.
//

import UIKit

class YuYinClassCollectionCell: UICollectionViewCell {

    @IBOutlet weak var YYImage: UIImageView!
    @IBOutlet weak var YYlabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }

}
