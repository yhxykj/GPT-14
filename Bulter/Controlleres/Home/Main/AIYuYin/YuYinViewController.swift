//
//  YuYinViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit

class YuYinViewController: UIViewController {

    @IBOutlet weak var viewTopLayout: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var home_Image: UIImageView!
    
//    var YYControll: YYloadingViewController?
    
    var selectRow: Int = 0
    var AidaString: String = ""
    var messages: [[String: String]] = NSMutableArray() as! [[String: String]]
    var font_name = ["zhiyue","zhiyan_emo","zhiyuan","zhimiao_emo","laotie","aishuo","ailun","sicheng"]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mineChatlishiMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MySpeeds.shared.stopPlay(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .horizontal
        sublyout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        sublyout.minimumInteritemSpacing = 12
        sublyout.minimumLineSpacing = 12
        sublyout.itemSize = CGSize(width: 95, height: 95)
        self.collectionView.collectionViewLayout = sublyout
        
        self.collectionView.register(UINib(nibName: "YuYinCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")

        let window = UIApplication.shared.keyWindow
        let topSafeArea = window?.safeAreaInsets.top ?? 0.0
        if topSafeArea > 25 {
            viewTopLayout.constant = 100
        }
        
        
    }
    
    func mineChatlishiMessage() {
        
        let lishi = UserDefaults.standard.object(forKey: "chat")
        if lishi != nil {
            self.messages = UserDefaults.standard.object(forKey: "chat") as! [[String: String]]
        }
    }

    @IBAction func Begin(_ sender: Any) {
        
        let YYControll = YYloadingViewController()
        YYControll.modalPresentationStyle = .fullScreen
        self.present(YYControll, animated: true)

        
    }
    
    func updateCellCenter() {
        
        if let voice_name = UserDefaults.standard.object(forKey: "font_name") as? String {
            var index = 0
            for name in font_name {
                if name.contains(voice_name) {
                    
                    selectRow = index
                    self.collectionView.reloadData()
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame {
                        let offsetX = cellFrame.origin.x + cellFrame.width / 2 - collectionView.frame.width / 2
                        let scrollPoint = CGPoint(x: offsetX, y: 0)
                        self.collectionView.setContentOffset(scrollPoint, animated: true)
                    }
                    
                    break
                }
                index += 1
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCellCenter()
    }

}

extension YuYinViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! YuYinCollectionViewCell
        cell.sepakImage.image = UIImage(named: "speak\(indexPath.row)")
        
        cell.sepakImage.layer.borderColor = UIColor.clear.cgColor
        if self.selectRow == indexPath.row {
            self.home_Image.image = UIImage(named: "speak\(indexPath.row)")
            cell.sepakImage.layer.borderColor = UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1.0).cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectRow = indexPath.row
        self.collectionView.reloadData()
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        let offsetX = cellFrame.origin.x + cellFrame.width / 2 - collectionView.frame.width / 2
        let scrollPoint = CGPoint(x: offsetX, y: 0)
        self.collectionView.setContentOffset(scrollPoint, animated: true)
        
        MySpeeds.shared.startPlay(fontName: font_name[indexPath.row], message: "您好，很高兴在茫茫人海中遇到您！", completionHandler: nil)
        UserDefaults.standard.set(font_name[indexPath.row], forKey: "font_name")
    }
    
}
