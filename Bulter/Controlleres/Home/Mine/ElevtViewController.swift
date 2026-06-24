//
//  ElevtViewController.swift
//  Bulter
//
//  Created by JJK on 2024/4/12.
//

import UIKit
import SVProgressHUD
import HandyJSON

class ElevtViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconTopLayout: NSLayoutConstraint!
    
    var orderId: String = ""
    var payId: String = ""
    var s_row = 0
    var Items = NSMutableArray()
    
    var listArray: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.keyWindow
        let topSafeArea = window?.safeAreaInsets.top ?? 0.0
        iconTopLayout.constant = topSafeArea+54
        
        scrollView.contentInsetAdjustmentBehavior = .never
        

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 16
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width - 78)/3, height: 125)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(UINib(nibName: "ElevtCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        list()
    }

    @IBAction func again(_ sender: Any) {
        ZKPayment.sharedTool().zk_resumptionOfPurchase()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func open(_ sender: Any) {
        placeOrder()
    }
    
    @IBAction func click(_ sender: UIButton) {
        if sender.tag == 0 {
            let webVC = WKWebViewController()
            webVC.modalPresentationStyle = .fullScreen
            webVC.webUrl = "https://v17geq2z088.feishu.cn/docx/CDu5dM56Wo2Be5xijx0cnrS0nxe?from=from_copylink"
            webVC.titleStr = "隐私政策"
            present(webVC, animated: true)
        }
        else if sender.tag == 1 {
            let webVC = WKWebViewController()
            webVC.modalPresentationStyle = .fullScreen
            webVC.webUrl = "https://v17geq2z088.feishu.cn/docx/Zydxd9NDmojZOGx48WSck43lnpb?from=from_copylink"
            webVC.titleStr = "用户协议"
            present(webVC, animated: true)
        }
        else if sender.tag == 2 {
            let webVC = WKWebViewController()
            webVC.modalPresentationStyle = .fullScreen
            webVC.webUrl = "https://v17geq2z088.feishu.cn/docx/CDu5dM56Wo2Be5xijx0cnrS0nxe?from=from_copylink"
            webVC.titleStr = "连续包月服务"
            present(webVC, animated: true)
        }
    }
    
    func list() {
        
        NetAlamofire.shared.normalPost(urlSuffix: "/app/meal/getVipMeal") { result in
            switch result {
            case.success(let model):

                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {

                        let array : NSArray = obj.object(forKey: "data") as! NSArray // as! 强制类型转换

                        for dic in array {
                            
                            if let user = AppVipModel.deserialize(from: dic as? [String: Any]) {
                                
                                self.Items.add(user)
                            }
                        }
                        

                        self.collectionView.reloadData()
                    }
                    else
                    {
                        UserDefaults.standard.set(2, forKey: "count")
                    }

                    NotificationCenter.default.post(name: NSNotification.Name("updateFreeCountNotificationName"), object: nil)

                }

                break
            case.failure(_):
                SVProgressHUD.showError(withStatus: "接口请求出错")
                break
            }
        }
    }
    
    func placeOrder() {
        
        if orderId.count == 0 {
            SVProgressHUD.showError(withStatus: "订单号不能为空")
            return
        }

        let url = "/app/order/create/\(orderId)"
        SVProgressHUD.show(withStatus: "下单中……")
        NetAlamofire.shared.normalPost(urlSuffix: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case.success(let model):
                SVProgressHUD.dismiss()
                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {
                        let order_sn: String = obj.object(forKey: "data") as! String
                        
                        self.buying(order_sn: order_sn)
                    }
                    else {
                        SVProgressHUD.showError(withStatus: obj["msg"] as? String)
                    }
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
    
    func buying(order_sn: String) {
        ZKPayment.sharedTool().zk_applyPayIosId(self.payId) { zk_type, data, tran_id in
            let request = data.base64EncodedString()
            print(request)
            
            if request.count > 0 {
                self.checkOrderStatus(pro_id: self.payId, order_sn: order_sn, receipt: request, tran_id: tran_id)
            }
            else {
                SVProgressHUD.dismiss()
            }
            
        }
    }
    
    func checkOrderStatus(pro_id: String, order_sn: String, receipt: String, tran_id: String) {
        
        var param = [String: Any]()
        param["productId"] = pro_id
        param["orderNo"] = order_sn
        param["receipt"] = receipt
        param["transactionId"] = tran_id
        param["type"] = AppType
        
        NetAlamofire.shared.normalPost(urlSuffix: "/app/order/ios/verify", body: param) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case.success(let model):
                
                if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                    if code == 200 {
                        
                        mineInfo()
                        UserDefaults.standard.set("1", forKey: "VIP")
                        UserDefaults.standard.synchronize()
                        self.dismiss(animated: true)
                    }
                    else {
                        SVProgressHUD.showError(withStatus: obj["msg"] as? String)
                    }
                }
                else {
                    SVProgressHUD.showError(withStatus: "订单校验失败")
                }
                
                break
            case.failure(_):
                SVProgressHUD.showError(withStatus: "接口请求出错")
                break
            }
        }
    }
    
}

extension ElevtViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ElevtCollectionViewCell
        let model: AppVipModel = Items[indexPath.row] as! AppVipModel
        
        cell.layer.borderWidth = 1
        cell.backgroundColor = .white
        cell.label.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
        cell.layer.borderColor = UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 0.27).cgColor
        cell.rmblabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        if s_row == indexPath.row {
            cell.layer.borderColor = UIColor(red: 2/255, green: 153/255, blue: 110/255, alpha: 1.0).cgColor
            cell.rmblabel.textColor = UIColor(red: 2/255, green: 153/255, blue: 110/255, alpha: 1.0)
            cell.backgroundColor = UIColor(red: 2/255, green: 153/255, blue: 110/255, alpha: 0.15)
            cell.label.backgroundColor = UIColor.white
            
            orderId = model.id!
            payId = model.iosId!
        }
        
        cell.timelabel.text = model.descript!
        cell.rmblabel.text = model.amount!
        cell.label.text = model.valueDescript!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        s_row = indexPath.row
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}
