//
//  SearchViewController.swift
//  Bulter
//
//  Created by JJK on 2024/4/17.
//

import UIKit
import ZKProgressHUD
import SVProgressHUD

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isCreate = false
    var classItems: [AppChuanNewItemRows] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .vertical
        sublyout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        sublyout.minimumInteritemSpacing = 0
        sublyout.minimumLineSpacing = 12
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.collectionViewLayout = sublyout
        
//        if isCreate == true {
            self.collectionView.register(UINib(nibName: "ChuangNewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
//        }
//        else {
//            self.collectionView.register(UINib(nibName: "BaShouCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
//        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func searchClick(_ sender: Any) {
        if searchTF.text?.isEmpty == true {
            ZKProgressHUD.showError("搜索不能为空")
            return
        }
        search()
        
        searchTF.resignFirstResponder()
    }
    
    func search() {
        var param = [String: Any]()
        param["aiName"] = searchTF.text!
        param["rows"] = 60
        if isCreate == true {
            param["aiType"] = "2"
        }
        else {
            param["aiType"] = "1"
        }
        
        NetAlamofire.shared.post(urlSuffix: "/ai/findSearchAi", body: param) { (result: Result<AppChuanNewItems, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 200 {
                    self.classItems = model.rows ?? []
                    self.collectionView.reloadData()
                    
                    if self.classItems.count == 0 {
                        ZKProgressHUD.showMessage("暂无数据")
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

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.classItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = self.classItems[indexPath.row]
        
//        if isCreate == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChuangNewCollectionCell
            cell.label.text = object.aiName
            cell.topIcon.isHidden = true
            if let url = object.headUrl {
                cell.icon.sd_setImage(with: URL(string: url))
            }
            
            return cell
//        }
//
//        else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BaShouCollectionViewCell
//            cell.label.text = object.aiName
//            cell.topIcon.isHidden = true
//            if let url = object.headUrl {
//                cell.iconImage.sd_setImage(with: URL(string: url))
//            }
//
//            return cell
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if isCreate == true {
            return CGSize(width: (self.view.frame.size.width - 46.5)/3, height: (self.view.frame.size.width - 46.5)/3)
//        }else {
//            return CGSize(width: (self.view.frame.size.width - 46.3)/2, height: 88)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.classItems[indexPath.row]
        let chat = ChatViewController()
        chat.isChat = true
        chat.typeID = object.id!
        chat.aiName = object.aiName!
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
}
