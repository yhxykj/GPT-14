//
//  BaShouHeaderViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/1.
//

import UIKit

class BaShouHeaderViewCell: UICollectionViewCell {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titlelabel.layer.cornerRadius = 4
        self.titlelabel.layer.masksToBounds = true
    }

}
