//
//  ChuangDetailsController.swift
//  Bulter
//
//  Created by JJK on 2024/4/10.
//

import UIKit
import SVProgressHUD

class ChuangDetailsController: UIViewController {

    @IBOutlet weak var nav_label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var bottomView = ChuangDetailsView()
    var chatView = ChuangAnswerView()
    
    var detailId: String = ""
    var nav_title: String = ""
    var sendMsg: String = ""
    var param: [String: Any] = [:]
    var datas = NSMutableArray()
    var isComplete = false
    var s_row = 0
    var s_section = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nav_label.text = nav_title

        let sublyout = UICollectionViewFlowLayout()
        sublyout.scrollDirection = .vertical
        sublyout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        sublyout.minimumInteritemSpacing = 0
        sublyout.minimumLineSpacing = 12
        self.collectionView.collectionViewLayout = sublyout
        
        self.collectionView.register(UINib(nibName: "ChuangDetailsItemsCell", bundle: nil), forCellWithReuseIdentifier: "items")
        self.collectionView.register(UINib(nibName: "ChuangDetailsTextCell", bundle: nil), forCellWithReuseIdentifier: "text")
        self.collectionView.register(UINib(nibName: "ChuangDetailsChangeCell", bundle: nil), forCellWithReuseIdentifier: "change")
        
        self.collectionView.register(UINib(nibName: "ChuangNewReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        
        bottomView = UINib(nibName: "ChuangDetailsView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ChuangDetailsView
        bottomView.dataSource = self
        view.addSubview(bottomView)
        bottomView.frame = CGRect(x: 0, y: self.view.frame.size.height+10, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        chatView = UINib(nibName: "ChuangAnswerView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ChuangAnswerView
        view.addSubview(chatView)
        chatView.frame = CGRect(x: 0, y: self.view.frame.size.height+10, width: self.view.frame.size.width, height: self.view.frame.size.height)

        detailTablelist()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(_:)), name: Notification.Name("DetailsTextContentName"), object: nil)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if self.datas.count != param.count {
            SVProgressHUD.showError(withStatus: "参数不完整！")
            return
        }
        
        let content = dictionaryToJson(targetObject: param)
        print(content)
        
        
        UIView.animate(withDuration: 0.31, animations: {
            self.chatView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
        })
        
        if isComplete == false {
            self.isComplete = true
            self.chatView.processParam(dict: param, msgStr: sendMsg, homeId: detailId)
        }
        
    }
    
    func dictionaryToJson(targetObject: Any) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: targetObject, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }
        
        return nil
    }
    
    
    @objc func textChange(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let value = userInfo["name"] as? String {
                
                param[value] = userInfo["content"]
                
                if let content = userInfo["content"] as? String {
                    sendMsg = content
                }
                
                print(value)
            }
        }
        
    }
    
    
    func detailTablelist() {
        var param = [String: Any]()
        param["id"] = detailId
        
        
        NetAlamofire.shared.normalPost(urlSuffix: "/ai/findAiCreation", body: param) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case.success(let model):
                
                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {
                        
                        if let array = obj["data"] as? NSArray {
//                            self.datas = array
                            self.datas.addObjects(from: array as! [Any])
                        }
                        
                        self.collectionView.reloadData()
                    }
                    else {
//                        SVProgressHUD.showError(withStatus: model.msg)
                    }
                }
                break
            case.failure(_):
                SVProgressHUD.showError(withStatus: "接口请求错误");
                break
            }
        }

    }

}

extension ChuangDetailsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dic = self.datas[section] as? [String: Any] {
            
            if let type = dic["type"] as? Int {
                if type == 1 {
                    return 1
                }
                else if type == 2 {
                    if let items = dic["content"] as? NSArray {
                        return items.count
                    }
                    return 1
                }
                else if type == 3 {
                    return 1
                }
            }
        }
        return 1
    }
        
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let dic = self.datas[indexPath.section] as? [String: Any] {
            if let type = dic["type"] as? Int {
                if type == 1 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "text", for: indexPath) as! ChuangDetailsTextCell
                    cell.textName = dic["name"] as! String
                    cell.textTF.placeholder = dic["content"] as? String
                    return cell
                    
                }
                else if type == 2 {
                    if let items = dic["content"] as? NSArray {
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "items", for: indexPath) as! ChuangDetailsItemsCell
                        cell.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 252/255, alpha: 1.0)
                        cell.label.text = items[indexPath.row] as? String
                        
                        cell.layer.borderWidth = 0
                        if let s_value = dic["select"] as? String {
                            if s_value.elementsEqual(cell.label.text!) {
                                cell.layer.borderWidth = 2
                                cell.layer.borderColor = UIColor(red: 81/255, green: 207/255, blue: 184/255, alpha: 1.0).cgColor
                            }
                        }
                        
                        
                        return cell
                    }
                    
                }
                else if type == 3 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "change", for: indexPath) as! ChuangDetailsChangeCell
                    cell.dataSource = self
                    
                    if let s_value = dic["select"] as? String {
                        cell.labeel.text = s_value
                        
                    }
                    
                    return cell
                }
            }
        }
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "items", for: indexPath)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if var dic = self.datas[indexPath.section] as? [String: Any] {
            if let type = dic["type"] as? Int {
                if type == 1 {
                    
                }
                else if type == 2 {
                    
                    if let items = dic["content"] as? NSArray {
                        dic["select"] = items[indexPath.row]
                        self.datas[indexPath.section] = dic
                        
                        let key = dic["name"] as! String
                        param[key] = items[indexPath.row]
                    }
                    
                    self.collectionView.reloadData()
                    
                }
                else if type == 3 {
                    
                }
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let dic = self.datas[indexPath.section] as? [String: Any] {
            if let type = dic["type"] as? Int {
                if type == 1 {
                    return CGSize(width: self.view.frame.self.width, height: 70)
                }
                else if type == 2 {
                    return CGSize(width: (self.view.frame.self.width-61)/3, height: 70)
                }
                else if type == 3 {
                    return CGSize(width: self.view.frame.self.width, height: 70)
                }
            }
        }
        
        return CGSize(width: self.view.frame.self.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.self.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            let replaceView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChuangNewReusableView
            
            if let dic = self.datas[indexPath.section] as? [String: Any] {
                replaceView.headerLabel.text = dic["name"] as? String
            }
            
            return replaceView
        }
        return UICollectionReusableView()
    }

}


extension ChuangDetailsController: ChuangDetailsChangeCellDataSource {
    func chuangDetailsChangeCell(cell: ChuangDetailsChangeCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            if let dic = self.datas[indexPath.section] as? [String: Any] {
                self.bottomView.selectItems(title: dic["name"] as! String, data: dic)
                
                s_section = indexPath.section
                s_row = indexPath.row
            }
        }
        
        
        
        UIView.animate(withDuration: 0.31, animations: {
            self.bottomView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        })
    }

}

extension ChuangDetailsController: ChuangDetailsViewDataSource {
    func chuangDetailsViewContent(content: String) {
        if var dic = self.datas[s_section] as? [String: Any] {
            
            dic["select"] = content
            self.datas[s_section] = dic
        
            let key = dic["name"] as! String
            param[key] = content
            
            let sections = IndexSet(integer: s_section)
            self.collectionView.reloadSections(sections)
        }
    }
}
