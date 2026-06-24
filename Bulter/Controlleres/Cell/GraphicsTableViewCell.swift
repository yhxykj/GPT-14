//
//  GraphicsTableViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit
import YYImage

protocol GraphicsTableViewCellDataSource: AnyObject {
    func deleteGraphicsTableViewCell(cell: GraphicsTableViewCell)
    func saveImageGraphicsTableViewCell(cell: GraphicsTableViewCell)
    func tapImageGraphicsTableViewCell(cell: GraphicsTableViewCell)
}

class GraphicsTableViewCell: UITableViewCell {
    weak var dataSource: GraphicsTableViewCellDataSource?
    
    @IBOutlet weak var picImage: YYAnimatedImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.picImage.layer.cornerRadius = 12;
        self.picImage.layer.masksToBounds = true
        self.picImage.layer.borderWidth = 2.5
        self.picImage.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    @IBAction func tapImage(_ sender: Any) {
        self.dataSource?.tapImageGraphicsTableViewCell(cell: self)
    }
    
    @IBAction func download(_ sender: UIButton) {

        self.dataSource?.saveImageGraphicsTableViewCell(cell: self)
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        self.dataSource?.deleteGraphicsTableViewCell(cell: self)
    }
    
    func saveImageToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}
