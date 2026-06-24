//
//  BaShouHeaderView.swift
//  Bulter
//
//  Created by JJK on 2024/4/1.
//

import UIKit
import SVProgressHUD

protocol BaShouHeaderViewDataSource: AnyObject {
    func baShouHeaderViewTitle(title: String)
}

class BaShouHeaderView: UIView {
    weak var dataSource: BaShouHeaderViewDataSource?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectIndex: Int = 0
    var header: [AppChuanNewHeader] = []
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .horizontal
        sublyout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        sublyout.minimumInteritemSpacing = 15
        sublyout.minimumLineSpacing = 12
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.collectionViewLayout = sublyout
        self.collectionView.register(UINib(nibName: "BaShouHeaderViewCell", bundle: nil), forCellWithReuseIdentifier: "header")

        if UserDefaults.standard.object(forKey: "AccountToken") != nil {
            self.baShouTheHeader()
        }
        
    }
    
    
    func baShouTheHeader() {
        var param = [String: Any]()
        param["aiType"] = "1"
        
        NetAlamofire.shared.post(urlSuffix: "/ai/findAiTypeList", body: param) { (result: Result<AppChuanNew, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 200 {
                    self.header = model.data ?? []
                    self.collectionView.reloadData()
                    
                    if self.header.count > 0 {
                        let object = self.header[0]
                        self.dataSource?.baShouHeaderViewTitle(title: object.dictValue!)
                    }
                }
                else {
                    SVProgressHUD.showError(withStatus: model.msg)
                }
                break
            case.failure(_):
                SVProgressHUD.showError(withStatus: "接口请求错误");
                break
            }
        }
    }
    
}

extension BaShouHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.header.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "header", for: indexPath) as! BaShouHeaderViewCell
        let object = self.header[indexPath.row]
        
        cell.titlelabel.text = object.dictLabel
        cell.backImage.image = UIImage(named: "")
        cell.titlelabel.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        if (self.selectIndex == indexPath.row) {
            cell.titlelabel.backgroundColor = .clear
            cell.backImage.image = UIImage(named: "助理_选中")
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.header[indexPath.row]
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.selectIndex = indexPath.row
        self.collectionView.reloadData()
        
        self.dataSource?.baShouHeaderViewTitle(title: object.dictValue!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 72, height: 35)
    }
}
