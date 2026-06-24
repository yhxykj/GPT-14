//
//  ChatHeaderViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit

protocol ChatHeaderViewCellDataSource: AnyObject {
    func chatHeaderViewCellContent(QStr: String)
}

class ChatHeaderViewCell: UITableViewCell {
    
    weak var dataSource: ChatHeaderViewCellDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func click(_ sender: UIButton) {
        if sender.tag == 0 {
            self.dataSource?.chatHeaderViewCellContent(QStr: "能告诉我一些浪漫且不油腻的小情话吗?")
        }
        else if sender.tag == 1 {
            self.dataSource?.chatHeaderViewCellContent(QStr: "如何一个人在一天之内完成一百万的小目标")
        }
       else if sender.tag == 2 {
           self.dataSource?.chatHeaderViewCellContent(QStr: "可以推荐几部经典的电影给我看吗?")
        }
    }
    
}
