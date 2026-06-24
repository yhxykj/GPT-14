//
//  NewBShouView.swift
//  Bulter
//
//  Created by JJK on 2024/4/12.
//

import UIKit
import ZKProgressHUD

protocol NewBShouViewDataSource: AnyObject {
    func updateMineNewBShouView()
}

class NewBShouView: UIView {
    
    weak var dataSource: NewBShouViewDataSource?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var holderlabel: UILabel!
    @IBOutlet weak var detailsTF: UITextView!
    
    var s_row = 0
    var imageUrl: String = ""
    var images = ["https://oss.yhxykj.com/im-prod/icon/14/5.png",
                  "https://oss.yhxykj.com/im-prod/icon/14/2.png",
                  "https://oss.yhxykj.com/im-prod/icon/14/1.png",
                  "https://oss.yhxykj.com/im-prod/icon/14/3.png",
                  "https://oss.yhxykj.com/im-prod/icon/14/4.png"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.detailsTF.delegate = self
        self.imageUrl = "https://oss.yhxykj.com/im-prod/icon/14/1.png"
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 13
        flowLayout.itemSize = CGSize(width: 65, height: 65)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.register(UINib(nibName: "NewItemCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
    }

    @IBAction func close(_ sender: Any) {
        UIView.animate(withDuration: 0.31, animations: {
            self.frame = CGRect(x: 0, y: self.frame.size.height+10, width: self.frame.size.width, height: self.frame.size.height)
        })
    }
    
    @IBAction func addCreate(_ sender: Any) {
        
        if nameTF.text?.count == 0 {
            ZKProgressHUD.showError("助理名称不能为空")
            return
        }
        if detailsTF.text.count == 0 {
            ZKProgressHUD.showError("助理描述不能为空")
            return
        }
        
       create()
        
    }
    
    func create() {
        var param = [String: Any]()
        param["aiName"] = self.nameTF.text
        param["aiBrief"] = self.detailsTF.text
        param["aiDetails"] = self.detailsTF.text
        param["headUrl"] = self.imageUrl
        param["aiType"] = "1"
        
        self.nameTF.text = ""
        self.detailsTF.text = ""
        self.holderlabel.text = "用一句话来描述您想您的助理帮你做什么呢？"
        
        NetAlamofire.shared.normalPost(urlSuffix: "/ai/addAi", body: param) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case.success(let model):
                
                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {
                        
                        UIView.animate(withDuration: 0.31, animations: {
                            self.frame = CGRect(x: 0, y: self.frame.size.height+10, width: self.frame.size.width, height: self.frame.size.height)
                        })
                        
                        ZKProgressHUD.showSuccess("新建成功")
                        self.dataSource?.updateMineNewBShouView()
                    }
                    else {
                        ZKProgressHUD.showError("新建失败");
                    }
                }
                break
            case.failure(_):
                ZKProgressHUD.showError("接口请求错误")
                break
            }
            
        }
    }
    
    
}

extension NewBShouView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if detailsTF.text.count == 0 {
            holderlabel.text = "用一句话来描述您想您的助理帮你做什么呢？"
        }
        else {
            holderlabel.text = ""
        }
    }
    
}

extension NewBShouView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewItemCollectionCell
        cell.backgroundColor = .clear
        
        cell.Icon.image = UIImage(named: "items\(indexPath.row)")
        if s_row == indexPath.row {
            cell.Icon.image = UIImage(named: "s_items\(indexPath.row)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        s_row = indexPath.row
        imageUrl = images[indexPath.row]
        self.collectionView.reloadData()
    }
    
}
