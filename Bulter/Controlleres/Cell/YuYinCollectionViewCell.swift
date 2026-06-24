//
//  YuYinCollectionViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/10.
//

import UIKit

class YuYinCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var sepakImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sepakImage.layer.borderWidth = 3
        sepakImage.layer.cornerRadius = 16
        sepakImage.layer.masksToBounds = true
    }

}
