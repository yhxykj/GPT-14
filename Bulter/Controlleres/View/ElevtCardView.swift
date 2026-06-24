//
//  ElevtCardView.swift
//  Bulter
//
//  Created by JJK on 2024/4/16.
//

import UIKit

protocol ElevtCardViewDataSource: AnyObject {
    func elevtCardViewPresent()
}

class ElevtCardView: UIView {
    
    weak var dataSource: ElevtCardViewDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func upgrades(_ sender: Any) {
        self.dataSource?.elevtCardViewPresent()
        
        transform = CGAffineTransformMakeScale(1.0, 1.0)
        alpha = 1.0
        UIView.animate(withDuration: 0.31) {
            self.transform = CGAffineTransformMakeScale(0.01, 0.01)
            self.alpha = 0.0
        }
    }
    
    
    @IBAction func close(_ sender: Any) {
        transform = CGAffineTransformMakeScale(1.0, 1.0)
        alpha = 1.0
        UIView.animate(withDuration: 0.31) {
            self.transform = CGAffineTransformMakeScale(0.01, 0.01)
            self.alpha = 0.0
        }
    }
    
    func showCardView() {
        transform = CGAffineTransformMakeScale(0.01, 0.01)
        alpha = 0.0
        UIView.animate(withDuration: 0.31) {
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.alpha = 1.0
        }
    }
    
}

