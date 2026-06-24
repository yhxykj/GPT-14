//
//  ChuangDetailsTextCell.swift
//  Bulter
//
//  Created by JJK on 2024/4/11.
//

import UIKit

class ChuangDetailsTextCell: UICollectionViewCell {
    
    

    @IBOutlet weak var textTF: UITextField!
    var textName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textTF.addTarget(self, action: #selector(textChange), for: .editingChanged)
    }

    @IBAction func clean(_ sender: Any) {
        self.textTF.text = ""
    }
    
    @objc func textChange() {
        let notificationData: [String: Any] = ["name": self.textName, "content": self.textTF.text != nil ? self.textTF.text! : ""]
        NotificationCenter.default.post(name: NSNotification.Name("DetailsTextContentName"), object: self, userInfo: notificationData)
    }
    
}
