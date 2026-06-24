//
//  ChuangNewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/28.
//

import UIKit
import SVProgressHUD
import SDWebImage

class ChuangNewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var header: [AppChuanNewHeader] = []
    var classItems: [AppChuanNewItemRows] = []
    
    var zhidinges: [[String: String?]] = NSMutableArray() as! [[String: String]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .vertical
        sublyout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        sublyout.minimumInteritemSpacing = 0
        sublyout.minimumLineSpacing = 12
        self.collectionView.collectionViewLayout = sublyout
        
        self.collectionView.register(UINib(nibName: "ChuangNewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")

        self.collectionView.register(UINib(nibName: "ChuangNewReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        mineTopData()
        
        if UserDefaults.standard.object(forKey: "AccountToken") != nil {
            self.chuanNewHeader()
        }
    }
    
    func mineTopData() {
        
        let lishi = UserDefaults.standard.object(forKey: "chuangzuo")
        if lishi != nil {
            zhidinges = UserDefaults.standard.object(forKey: "chuangzuo") as! [[String: String]]
        }
        
    }
    
    @IBAction func qianWangSousuo(_ sender: UIButton) {
        let searchVC = SearchViewController()
        searchVC.isCreate = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func chuanNewHeader() {
        var param = [String: Any]()
        param["aiType"] = "2"
        
        NetAlamofire.shared.post(urlSuffix: "/ai/findAiTypeList", body: param) { (result: Result<AppChuanNew, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 200 {
                    self.header = model.data ?? []
                    self.chuanNewRows()
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
    
    
    
    func chuanNewRows() {
        var param = [String: Any]()
        param["aiType"] = "2"
        param["createType"] = "20"
        param["rows"] = 60
        
        NetAlamofire.shared.post(urlSuffix: "/ai/findAi", body: param) { (result: Result<AppChuanNewItems, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 200 {
                    self.classItems = model.rows ?? []
                    self.collectionView.reloadData()
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

extension ChuangNewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return header.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return zhidinges.count
        }

        var items = [Any]()
        let dictLabel = header[section].dictValue
        for index in 0..<classItems.count {
            let createType = classItems[index].createType
            
            if createType == dictLabel {
                items.append(createType)
            }
        }
        
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChuangNewCollectionCell
        
        newCell.dataSource = self
        
        if indexPath.section == 0 {
            let object = zhidinges[indexPath.row]
            
            newCell.label.text = object["aiName"]!
            if let url = object["headUrl"], url != nil {
                newCell.icon.sd_setImage(with: URL(string: url!))
            }
            newCell.topIcon.setImage(UIImage(named: "直下"), for: .normal)
            return newCell
        }
        
        let dictLabel = header[indexPath.section].dictValue
        var items: [[String: String?]] = NSMutableArray() as! [[String: String]]
        for index in 0..<classItems.count {
            let createType = classItems[index].createType
            if createType == dictLabel {
                let obj = ["aiName":classItems[index].aiName,"aiBrief":classItems[index].aiBrief,"headUrl":classItems[index].headUrl]
                items.append(obj)
            }
        }
        
        let dic = items[indexPath.row]
        newCell.label.text = dic["aiName"]!
        newCell.topIcon.setImage(UIImage(named: "直上"), for: .normal)
        
        if let url = dic["headUrl"], url != nil  {
            newCell.icon.sd_setImage(with: URL(string: url!))
        }
        
        
        
        return newCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let dic = zhidinges[indexPath.row]
            let chat = ChatViewController()
            chat.isChat = true
            chat.typeID = dic["id"]!!
            chat.aiName = dic["aiName"]!!
            self.navigationController?.pushViewController(chat, animated: true)
            return
        }
        
        
        let dictLabel = header[indexPath.section].dictValue
        var items: [[String: String?]] = NSMutableArray() as! [[String: String]]
        for index in 0..<classItems.count {
            let createType = classItems[index].createType
            if createType == dictLabel {
                let obj = ["aiName":classItems[index].aiName,"aiBrief":classItems[index].aiBrief,"id":classItems[index].id]
                items.append(obj)
            }
        }
        
        let dic = items[indexPath.row]
        let chat = ChatViewController()
        chat.isChat = true
        chat.typeID = dic["id"]!!
        chat.aiName = dic["aiName"]!!
        self.navigationController?.pushViewController(chat, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.size.width - 49)/3, height: (self.view.frame.size.width - 49)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.self.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            let replaceView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChuangNewReusableView
            replaceView.headerLabel.text = header[indexPath.section].dictLabel
            return replaceView
        }
        return UICollectionReusableView()
    }

    
}

//extension ChuangNewController: BaShouCollectionViewCellDataSource {
//
//    func baShouCollectionViewCelldata(cell: BaShouCollectionViewCell) {
//        if let indexPath = self.collectionView.indexPath(for: cell) {
//
//            if indexPath.section == 0 {
//                zhidinges.remove(at: indexPath.row)
//                self.collectionView.reloadData()
//                UserDefaults.standard.set(zhidinges, forKey: "chuangzuo")
//                return
//            }
//
//            let dictLabel = header[indexPath.section].dictValue
//
//            var items: [[String: String?]] = NSMutableArray() as! [[String: String]]
//            for index in 0..<classItems.count {
//                let createType = classItems[index].createType
//                if createType == dictLabel {
//                    let obj = ["aiName":classItems[index].aiName,"aiBrief":classItems[index].aiBrief,"headUrl":classItems[index].headUrl,"id":classItems[index].id]
//
//                    items.append(obj)
//                }
//            }
//            let dic = items[indexPath.row]
//
//            let containsValue = zhidinges.contains { dictionary in
//                dictionary.values.contains(dic["aiName"]!)
//            }
//            print(containsValue)
//            if containsValue == true {
//                return
//            }
//
//            zhidinges.append(dic)
//            UserDefaults.standard.set(zhidinges, forKey: "chuangzuo")
//        }
//
//        self.collectionView.reloadData()
//    }
//}
//

extension ChuangNewController: ChuangNewCollectionCellDataSource {
    func chuangNewCollectionCelldata(cell: ChuangNewCollectionCell) {
        if let indexPath = self.collectionView.indexPath(for: cell) {

            if indexPath.section == 0 {
                zhidinges.remove(at: indexPath.row)
                self.collectionView.reloadData()
                UserDefaults.standard.set(zhidinges, forKey: "chuangzuo")
                return
            }

            let dictLabel = header[indexPath.section].dictValue

            var items: [[String: String?]] = NSMutableArray() as! [[String: String]]
            for index in 0..<classItems.count {
                let createType = classItems[index].createType
                if createType == dictLabel {
                    let obj = ["aiName":classItems[index].aiName,"aiBrief":classItems[index].aiBrief,"headUrl":classItems[index].headUrl,"id":classItems[index].id]

                    items.append(obj)
                }
            }
            let dic = items[indexPath.row]

            let containsValue = zhidinges.contains { dictionary in
                dictionary.values.contains(dic["aiName"]!)
            }
            print(containsValue)
            if containsValue == true {
                return
            }

            zhidinges.append(dic)
            UserDefaults.standard.set(zhidinges, forKey: "chuangzuo")
        }

        self.collectionView.reloadData()

    }
}
