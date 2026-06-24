//
//  MineViewController.swift
//  Bulter
//
//  Created by JJK on 2024/4/12.
//

import UIKit
import ZKProgressHUD

class MineViewController: UIViewController {

    @IBOutlet weak var aiNamelabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emailText: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let vipValue = UserDefaults.standard.string(forKey: "VIP"), vipValue == "1" {
            if let time = UserDefaults.standard.object(forKey: "Time") as? String {
                if time.count > 10 {
                    let endIndex = time.index(time.startIndex, offsetBy: 9)
                    let substring = time[time.startIndex...endIndex]
                    label.text = "会员到期时间\(substring)"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = UserDefaults.standard.object(forKey: "name") as? String {
            aiNamelabel.text = name
        }
        
        kefuEmail()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func fuzhi(_ sender: Any) {
        
        if ((aiNamelabel.text?.isEmpty) != nil){
            let pasteboard = UIPasteboard.general
            pasteboard.string = aiNamelabel.text
            ZKProgressHUD.showMessage("复制完成")
            return
        }
        ZKProgressHUD.showError("复制失败")
        
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
            if ((emailText.text?.isEmpty) != nil){
                let pasteboard = UIPasteboard.general
                pasteboard.string = emailText.text
                ZKProgressHUD.showMessage("复制完成")
                return
            }
            ZKProgressHUD.showError("复制失败")
        }
        else if sender.tag == 3 {
            
            let actionSheet = UIAlertController(title: "提示", message: "你确定要清空聊天记录吗？清空之后不能再找回", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "再想想", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "确定", style: .default) { _ in

                if let appBundle = Bundle.main.bundleIdentifier {
                    
                    var count = 0
                    if let free = UserDefaults.standard.object(forKey: "free") as? Int {
                        count = free
                    }
                    
                    UserDefaults.standard.removePersistentDomain(forName: appBundle)
                    NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateTableViewNotificationName"), object: nil)
                    checkAliToken()
                    UserDefaults.standard.set(count, forKey: "free")
                }
                
            }
            actionSheet.addAction(cancelAction)
            actionSheet.addAction(okAction)
            self.present(actionSheet, animated: true, completion: nil)
            
            
        }
    }
    
    @IBAction func chatVip(_ sender: Any) {
        let elevtVC = ElevtViewController()
        elevtVC.modalPresentationStyle = .fullScreen
        present(elevtVC, animated: true)
    }
    
    func kefuEmail() {
        NetAlamofire.shared.post(urlSuffix: "/app/email") { (result: Result<AppAiSketch, NetworkError>) in
            
            switch result {
            case.success(let model):
                if model.code == 200 {
                    self.emailText.text = model.data
                }
                
                break
                
            case.failure(_):
                
                break
            }
            
        }
    }
    
}
