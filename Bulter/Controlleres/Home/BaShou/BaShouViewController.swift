//
//  BaShouViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/28.
//

import UIKit
import SVProgressHUD

class BaShouViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var header: [AppChuanNewHeader] = []
    var classItems: [AppChuanNewItemRows] = []
    var newView = NewBShouView()
    var title_row: String = "0"
    var topItems: [AppChuanNewItemRows] = []
    var zhidinges: [[String: String?]] = NSMutableArray() as! [[String: String]]
    
    var items = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newView = UINib(nibName: "NewBShouView", bundle: nil).instantiate(withOwner: self, options: nil).first as! NewBShouView
        view.addSubview(newView)
        newView.dataSource = self
        newView.frame = CGRect(x: 0, y: self.view.frame.size.height+10, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .vertical
        sublyout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        sublyout.minimumInteritemSpacing = 0
        sublyout.minimumLineSpacing = 12
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.collectionViewLayout = sublyout

        self.collectionView.register(UINib(nibName: "ChuangNewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView.register(UINib(nibName: "ChuangNewReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        mineTopData()
        
    }
    
    func headerTitle() {
        baShouClassRows()
    }
    
    func mineTopData() {
        
        let lishi = UserDefaults.standard.object(forKey: "help")
        if lishi != nil {
            zhidinges = UserDefaults.standard.object(forKey: "help") as! [[String: String]]
        }
        collectionView.reloadData()
        
    }

    @IBAction func qianWangSousuo(_ sender: UIButton) {
        let searchVC = SearchViewController()
        searchVC.isCreate = false
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func newAdd(_ sender: Any) {
        UIView.animate(withDuration: 0.31, animations: {
            self.newView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
        })
    }
    
    func chuanNewHeader() {
        var param = [String: Any]()
        param["aiType"] = "1"
        
        NetAlamofire.shared.post(urlSuffix: "/ai/findAiTypeList", body: param) { (result: Result<AppChuanNew, NetworkError>) in
            switch result {
            case.success(let model):
                print(model.data)
                if model.code == 200 {
                    self.header = model.data ?? []
                    self.baShouClassRows()
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
    
    
    
    func baShouClassRows() {
        var param = [String: Any]()
        param["aiType"] = "1"

        SVProgressHUD.show()
        NetAlamofire.shared.normalPost(urlSuffix: "/ai/findAiList", body: param) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case.success(let model):
                SVProgressHUD.dismiss()
                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {
                        self.items = obj["data"] as! NSArray
                       
                    }
                    self.collectionView.reloadData()
                }
                else {
                    SVProgressHUD.showError(withStatus: "下单失败")
                }
                
                break
            case.failure(_):
                SVProgressHUD.showError(withStatus: "接口请求出错")
                break
            }
            
        }
        

    }
    
    func savebsTopItems() {
        UserDefaults.standard.set(zhidinges, forKey: "help")
    }

}

extension BaShouViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
        return header.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return zhidinges.count
        }
        
        if let obj = items[section] as? [String: Any] {
            if let data = obj["aiType"] as? [[String: Any]] {
                return data.count
            }
        }
        
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChuangNewCollectionCell
        cell.dataSource = self
        
        
        if indexPath.section == 0 {
           
            let object = self.zhidinges[indexPath.row]
            cell.label.text = object["aiName"]!
            if let url = object["headUrl"], url != nil {
                cell.icon.sd_setImage(with: URL(string: url!))
            }
            cell.topIcon.setImage(UIImage(named: "直下"), for: .normal)
            
            return cell
        }

        
        
        if let obj = items[indexPath.section] as? [String: Any] {
            if let data = obj["aiType"] as? [[String: Any]] {
                
                let dic = data[indexPath.row]
                
                cell.label.text = dic["aiName"] as? String
                cell.topIcon.setImage(UIImage(named: "直上"), for: .normal)
                
                if let url = dic["headUrl"], url != nil  {
                    cell.icon.sd_setImage(with: URL(string: url as! String))
                }
                
            }
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width - 49.2)/3, height: (self.view.frame.size.width - 49.2)/3)
//        return CGSize(width: (self.view.frame.size.width - 45)/2, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.self.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            let replaceView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChuangNewReusableView
            
            if let obj = items[indexPath.section] as? [String: Any], let aiTypeName = obj["aiTypeName"] as? String {
                replaceView.headerLabel.text = aiTypeName
            }
            
            return replaceView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let object = zhidinges[indexPath.row]
            let chat = ChatViewController()
            chat.isChat = true
            chat.typeID = object["id"]!!
            chat.aiName = object["aiName"]!!
            self.navigationController?.pushViewController(chat, animated: true)
            return
        }
        
        if let obj = items[indexPath.section] as? [String: Any] {
            if let data = obj["aiType"] as? [[String: Any]] {
                
                let object = data[indexPath.row]
                let chat = ChatViewController()
                chat.isChat = true
                chat.typeID = object["id"] as! String
                chat.aiName = object["aiName"] as! String
                self.navigationController?.pushViewController(chat, animated: true)
                
            }
        }
        
    }
}

extension BaShouViewController: ChuangNewCollectionCellDataSource {
    func chuangNewCollectionCelldata(cell: ChuangNewCollectionCell) {
        if let indexPath = self.collectionView.indexPath(for: cell) {
            
            if indexPath.section == 0 {
                zhidinges.remove(at: indexPath.row)
                self.collectionView.reloadData()
                savebsTopItems()
                return
            }
            
            if let obj = items[indexPath.section] as? [String: Any] {
                if let data = obj["aiType"] as? [[String: Any]] {
                    
                    let dic = data[indexPath.row]
                    
                    let containsValue = zhidinges.contains { dictionary in
                        dictionary.values.contains(dic["aiName"] as? String)
                    }
                    if containsValue == true {
                        return
                    }
                    
                    zhidinges.append(["aiName":dic["aiName"] as? String,"aiBrief":dic["aiBrief"] as? String,"headUrl":dic["headUrl"] as? String,"id":dic["id"] as? String])
                    
                }
            }

            
        }
        savebsTopItems()
        self.collectionView.reloadData()
    }
}

extension BaShouViewController: BaShouCollectionViewCellDataSource {
    func baShouCollectionViewCelldata(cell: BaShouCollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: cell) {
            
            if title_row.elementsEqual("0") {
                zhidinges.remove(at: indexPath.row)
                self.collectionView.reloadData()
                savebsTopItems()
                return
            }
            
            let object = self.classItems[indexPath.row]
            
            let containsValue = zhidinges.contains { dictionary in
                dictionary.values.contains(object.aiName)
            }
            if containsValue == true {
                return
            }
            
            
            if let obj = items[indexPath.section] as? [String: Any] {
                if let data = obj["aiType"] as? [[String: Any]] {
                    
                    let dic = data[indexPath.row]
                    
                    let containsValue = zhidinges.contains { dictionary in
                        dictionary.values.contains(dic["aiName"] as? String)
                    }
                    if containsValue == true {
                        return
                    }
                    
                    zhidinges.append(["aiName":dic["aiName"] as? String,"aiBrief":dic["aiBrief"] as? String,"headUrl":dic["headUrl"] as? String,"id":dic["id"] as? String])
//                    self.topItems.append(dic)
                    
                    
//                    cell.label.text = dic["aiName"] as? String
//                    cell.topIcon.setImage(UIImage(named: "直上"), for: .normal)
//
//                    if let url = dic["headUrl"], url != nil  {
//                        cell.icon.sd_setImage(with: URL(string: url as! String))
//                    }
                    
                }
            }
            
        }
        savebsTopItems()
        self.collectionView.reloadData()
        
    }
}

extension BaShouViewController: BaShouHeaderViewDataSource {
    func baShouHeaderViewTitle(title: String) {
        title_row = title
        if title.elementsEqual("0") {
            collectionView.reloadData()
            return
        }
//        self.baShouClassRows(createType: title)
    }
}

extension BaShouViewController: NewBShouViewDataSource {
    func updateMineNewBShouView() {
        
        chuanNewHeader()
    }
}
