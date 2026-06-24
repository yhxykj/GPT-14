//
//  ChuangNewCollectionCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/28.
//

import UIKit

protocol ChuangNewCollectionCellDataSource: AnyObject {
    func chuangNewCollectionCelldata(cell: ChuangNewCollectionCell)
}

class ChuangNewCollectionCell: UICollectionViewCell {

    weak var dataSource: ChuangNewCollectionCellDataSource?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var topIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 11
        self.layer.masksToBounds = true
    }

    @IBAction func downloadClick(_ sender: UIButton) {
   
        self.dataSource?.chuangNewCollectionCelldata(cell: self)
        
    }
}
