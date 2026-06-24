//
//  MainViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var titleImage: UIImageView!
    var scrollView: UIScrollView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width*3, height: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView = UIScrollView()
        self.scrollView.backgroundColor = .clear
        self.view.addSubview(self.scrollView)
        self.scrollView.isScrollEnabled = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(headerView)
        headerView.isHidden = true
        headerView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(110)
            make.top.equalTo(-200)
        }
        
        let window = UIApplication.shared.keyWindow
        let topSafeArea = window?.safeAreaInsets.top ?? 0.0
        print("Top safe area: \(topSafeArea)")

        let chatVC = ChatViewController()
        self.scrollView.addSubview(chatVC.view)
        self.addChild(chatVC)
        chatVC.view.snp.makeConstraints { make in
            make.left.top.equalTo(0)
            make.height.equalTo(UIScreen.main.bounds.size.height-topSafeArea-44)
            make.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        let graphicsVC = GraphicsViewController()
        self.scrollView.addSubview(graphicsVC.view)
        self.addChild(graphicsVC)
        graphicsVC.view.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(UIScreen.main.bounds.size.width)
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.height.equalTo(UIScreen.main.bounds.size.height-topSafeArea-44)
        }
        
        let yuYinVC = YuYinViewController()
        self.scrollView.addSubview(yuYinVC.view)
        self.addChild(yuYinVC)
        yuYinVC.view.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(UIScreen.main.bounds.size.width*2)
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.bottom.equalTo(UIScreen.main.bounds.size.height-64)
        }
        
    }

    func glideHeaderView() {
        headerView.isHidden = false
        UIView.animate(withDuration: 2.1) {
            self.headerView.snp.remakeConstraints { make in
                make.top.left.right.equalTo(0)
                make.height.equalTo(110)
            }
        }
    }
    
    func upslideHeaderView() {
        headerView.isHidden = true
        UIView.animate(withDuration: 2.1) {
            self.headerView.snp.remakeConstraints { make in
                make.left.right.equalTo(0)
                make.height.equalTo(110)
                make.top.equalTo(-200)
            }
        }
        
    }
    
    @IBAction func titleClick(_ sender: UIButton) {
        if sender.tag == 0 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.titleImage.image = UIImage(named: "AI对话")
            NotificationCenter.default.post(name: NSNotification.Name("MainChooseTitle"), object: "open_对话")
        }
        else if sender.tag == 1 {
            MySpeeds.shared.stopPlay()
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
            self.titleImage.image = UIImage(named: "AI绘画")
            NotificationCenter.default.post(name: NSNotification.Name("MainChooseTitle"), object: "open_绘画")
        }
        else if sender.tag == 2 {
            MySpeeds.shared.stopPlay()
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.size.width*2, y: 0), animated: true)
            self.titleImage.image = UIImage(named: "AI语音")
            NotificationCenter.default.post(name: NSNotification.Name("MainChooseTitle"), object: "open_语音")
        }
        
    }
    
    

}
