//
//  GraphicsHeaderViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit

protocol GraphicsHeaderViewCellDataSource: AnyObject {
    func defaultQuestionGraphicsHeaderViewCell(content: String)
}

class GraphicsHeaderViewCell: UITableViewCell {
    
    weak var dataSource: GraphicsHeaderViewCellDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func click(_ sender: UIButton) {
        if sender.tag == 0 {
            self.dataSource?.defaultQuestionGraphicsHeaderViewCell(content: "输入想要的内容，例如：画一张可爱的小猫")
        }
        else if sender.tag == 1 {
            self.dataSource?.defaultQuestionGraphicsHeaderViewCell(content: "输入你想要的风格，例如：3d卡通、素描、Q版")
        }
        else if sender.tag == 2 {
            self.dataSource?.defaultQuestionGraphicsHeaderViewCell(content: "示例：一张正在玩水的调皮小猫，Q版风格")
        }
    }
}
