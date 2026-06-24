//
//  BaShouCollectionViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/1.
//

import UIKit

protocol BaShouCollectionViewCellDataSource: AnyObject {
    func baShouCollectionViewCelldata(cell: BaShouCollectionViewCell)
}

class BaShouCollectionViewCell: UICollectionViewCell {
    
    weak var dataSource: BaShouCollectionViewCellDataSource?

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var topIcon: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 252/255.0, alpha: 1.0)
    }

    @IBAction func top(_ sender: Any) {
        self.dataSource?.baShouCollectionViewCelldata(cell: self)
    }
}
