//
//  ChuangDetailsChangeCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/11.
//

import UIKit

protocol ChuangDetailsChangeCellDataSource: AnyObject {
    func chuangDetailsChangeCell(cell: ChuangDetailsChangeCell)
}

class ChuangDetailsChangeCell: UICollectionViewCell {

    weak var dataSource: ChuangDetailsChangeCellDataSource?
    
    
    @IBOutlet weak var labeel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    @IBAction func down(_ sender: Any) {
        self.dataSource?.chuangDetailsChangeCell(cell: self)
    }
    
}
