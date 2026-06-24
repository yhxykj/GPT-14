//
//  HomeViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit
import SnapKit
import SVProgressHUD
//import Reachability

class HomeViewController: UIViewController {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    var mainVC: MainViewController!
    var newVC: ChuangNewController!
    var baShouVC: BaShouViewController!
    var titleStr: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.object(forKey: "AccountToken") != nil {
            checkAliToken()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(titleClick(_:)), name: NSNotification.Name("MainChooseTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountNumberLogin), name: NSNotification.Name("loginFailNotificationName"), object: nil)
        
        titleStr = "close_对话"
        
        self.mainVC = MainViewController()
        self.bgView.addSubview(self.mainVC.view)
        self.addChild(self.mainVC)
        self.mainVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.newVC = ChuangNewController()
        self.bgView.addSubview(self.newVC.view)
        self.addChild(self.newVC)
        self.newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.baShouVC = BaShouViewController()
        self.bgView.addSubview(self.baShouVC.view)
        self.addChild(self.baShouVC)
        self.baShouVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.newVC.view.isHidden = true
        self.baShouVC.view.isHidden = true
        
        
        if UserDefaults.standard.object(forKey: "AccountToken") == nil {
           
            self.accountNumberLogin()
            
        }
        else {
            mineInfo()
        }
        
    }
    
    @IBAction func home(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            self.mainVC.glideHeaderView()
            if titleStr == "open_对话" {
                titleImage.image = UIImage(named: "open_对话")
            }
            else if titleStr == "open_绘画" {
                titleImage.image = UIImage(named: "open_绘画")
            }
            else {
                titleImage.image = UIImage(named: "open_语音")
            }
        }
        else {
            self.mainVC.upslideHeaderView()
            if titleStr == "open_对话" {
                titleImage.image = UIImage(named: "close_对话")
            }
            else if titleStr == "open_绘画" {
                titleImage.image = UIImage(named: "close_绘画")
            }
            else {
                titleImage.image = UIImage(named: "close_语音")
            }
        }
        self.mainVC.view.isHidden = false
        self.newVC.view.isHidden = true
        self.baShouVC.view.isHidden = true
        
    }
    
    @IBAction func center(_ sender: Any) {
        titleImage.image = UIImage(named: "open_创作")
        self.mainVC.view.isHidden = true
        self.baShouVC.view.isHidden = true
        self.newVC.view.isHidden = false
        MySpeeds.shared.stopPlay()
        
        if newVC.classItems.count == 0 {
            newVC.chuanNewHeader()
        }
    }
    
    @IBAction func assitant(_ sender: Any) {
        titleImage.image = UIImage(named: "open_助理")
        self.mainVC.view.isHidden = true
        self.baShouVC.view.isHidden = false
        self.newVC.view.isHidden = true
        MySpeeds.shared.stopPlay()
        
        if baShouVC.items.count == 0 {
            baShouVC.headerTitle()
        }
    }
    
    @IBAction func setting(_ sender: Any) {
   
        let mineVC = MineViewController()
        navigationController?.pushViewController(mineVC, animated: true)
        
    }
    
    @IBAction func vipCenter(_ sender: Any) {
        
        let elevtVC = ElevtViewController()
        elevtVC.modalPresentationStyle = .fullScreen
        present(elevtVC, animated: true)
        
    }
    
    @objc func titleClick(_ notification: Notification) {
        if let object = notification.object as? String {
            titleImage.image = UIImage(named: object)
            titleStr = object
        }
    }
    
    
    
    
    
    @objc func accountNumberLogin() {
        var param = [String: Any]()
        param["accountNumber"] = getAccountNumberIdentifier()
        param["type"] = AppType
        
        NetAlamofire.shared.post(urlSuffix: "/app/sms/login", body: param) { (result: Result<AppLogin, NetworkError>) in
            switch result {
            case .success(let model):
                if model.code == 200 {
                    
                    let AccountToken: String = model.data!["token"]!
                    UserDefaults.standard.set(AccountToken, forKey: "AccountToken")
                    
                    mineInfo()
                    checkAliToken()
                }
                
            case .failure(_):
                
//                SVProgressHUD.showError(withStatus: "接口请求错误");
                
                break
            }
        }
    }

}

