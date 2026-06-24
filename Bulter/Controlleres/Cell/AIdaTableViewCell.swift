//
//  AIdaTableViewCell.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit
import YYImage
import SVProgressHUD

protocol AIdaTableViewCellDataSource: AnyObject {
    func deleteAIdaTableViewCell(cell: AIdaTableViewCell)
    func buttonplayVoiceAIdaTableViewCell(cell: AIdaTableViewCell)
}

class AIdaTableViewCell: UITableViewCell {
    
    weak var dataSource: AIdaTableViewCellDataSource?

    @IBOutlet weak var aidAlabel: UILabel!
    @IBOutlet weak var aidAimage: UIButton!
    @IBOutlet weak var gifImage: YYAnimatedImageView!
    var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let address = Bundle.main.path(forResource: "gundong", ofType: "gif") {
            if let section = NSData(contentsOfFile: address) {
                if let gundImg = YYImage(data: section as Data) {
                    gifImage.image = gundImg
                }
            }
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func aidAdelete(_ sender: UIButton) {
        if self.aidAlabel.text?.count == 0 {
            return
        }
        MySpeeds.shared.stopPlay(false)
        self.dataSource?.deleteAIdaTableViewCell(cell: self)
    }
    
    @IBAction func aidApass(_ sender: Any) {
        if self.aidAlabel.text?.count == 0 {
            return
        }
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.aidAlabel.text
        SVProgressHUD.showSuccess(withStatus: "复制完成")
    }
    
    @IBAction func aidAbroadcast(_ sender: UIButton) {
        
        if self.aidAlabel.text?.count == 0 {
            return
        }
        
        if button == nil {
            button = sender
        }
        
        if button.isSelected == true && button == sender {
            MySpeeds.shared.stopPlay()
            button.setImage(UIImage(named: "喇叭"), for: .normal)
            button.isSelected = false
            return
        }

        MySpeeds.shared.stopPlay()
        button.setImage(UIImage(named: "喇叭"), for: .normal)
        sender.setImage(UIImage(named: "形状"), for: .normal)
        

        MySpeeds.shared.startPlay(message: self.aidAlabel.text!) { AlisPlayStatus in
            DispatchQueue.main.async { [self] in
                switch AlisPlayStatus {
                    case .start:
                    sender.isSelected = true
                    button.isSelected = true
                    sender.setImage(UIImage(named: "形状"), for: .normal)
                    break
                    case .end:
                    sender.isSelected = false
                    button.isSelected = false
                    sender.setImage(UIImage(named: "喇叭"), for: .normal)
                    break
                }
            }
        }
        button = sender
    }
    
}
