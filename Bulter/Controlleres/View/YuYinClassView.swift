//
//  YuYinClassView.swift
//  Bulter
//
//  Created by JJK on 2024/4/2.
//

import UIKit

protocol YuYinClassViewDataSource: AnyObject {
    func yuYinClassViewConfirm(imageName: String, yyName: String)
}

class YuYinClassView: UIView {
    weak var dataSource: YuYinClassViewDataSource?
    
    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var contents = ["御姐女声","标准女声","电台女声","知心女声","诙谐男声","标准男声","磁性男声","青年男声"]
    var font_name = ["zhiyue","zhiyan_emo","zhiyuan","zhimiao_emo","laotie","aishuo","ailun","sicheng"]
    var selectString = ""
    var selectInt: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .vertical
        sublyout.sectionInset = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        sublyout.minimumInteritemSpacing = 12
        sublyout.minimumLineSpacing = 15
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.collectionViewLayout = sublyout
        self.collectionView.register(UINib(nibName: "YuYinClassCollectionCell", bundle: nil), forCellWithReuseIdentifier: "class")
        
        slider.minimumValue = 0.7
        slider.maximumValue = 1.5
        slider.setThumbImage(UIImage(named: "椭圆形"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        if let rate = UserDefaults.standard.object(forKey: "rate") as? Float {
            if rate > 0.5 {
                slider.value = rate
                speed.text = rate as? String
            }
        }
        else {
            slider.value = 1.0
            speed.text = "1.0"
        }
    }
    
    @IBAction func confirm(_ sender: Any) {
        self.dataSource?.yuYinClassViewConfirm(imageName: selectString, yyName: titleLabel.text!)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        speed.text = String(format: "%.2fx", value)
        UserDefaults.standard.setValue(speed.text, forKey: "rate")
    }

}

extension YuYinClassView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "class", for: indexPath) as! YuYinClassCollectionCell
        cell.YYImage.image = UIImage(named: "位图备份\(indexPath.row)")
        cell.YYlabel.text = contents[indexPath.row]
        
        cell.layer.borderWidth = 0
        cell.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 252/255.0, alpha: 1.0)
        if selectInt == indexPath.row {
            cell.backgroundColor = UIColor(red: 212/255.0, green: 231/255.0, blue: 255/255.0, alpha: 1.0)
            cell.layer.borderColor = UIColor(red: 74/255.0, green: 207/255.0, blue: 255/255.0, alpha: 1.0).cgColor
            cell.layer.borderWidth = 2
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectInt = indexPath.row
        titleLabel.text = contents[indexPath.row]
        selectString = "位图备份\(indexPath.row)"
        Icon.image = UIImage(named: selectString)
        self.collectionView.reloadData()
        
        MySpeeds.shared.startPlay(fontName: font_name[indexPath.row], message: "您好，很高兴在茫茫人海中遇到您！", completionHandler: nil)
        UserDefaults.standard.set(font_name[indexPath.row], forKey: "font_name")
        UserDefaults.standard.set(selectString, forKey: "voiceImg")
        UserDefaults.standard.set(titleLabel.text, forKey: "voice_name")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width-71)/4, height: 80)
    }
}
