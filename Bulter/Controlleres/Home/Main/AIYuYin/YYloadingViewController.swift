//
//  YYloadingViewController.swift
//  Bulter
//
//  Created by JJK on 2024/4/2.
//

import UIKit

class YYloadingViewController: UIViewController {

    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var statuslabel: UILabel!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var speakView: UIView!
    @IBOutlet weak var listenImage: UIImageView!
    @IBOutlet weak var listenView: UIView!
    
    @IBOutlet weak var come_view1: UIView!
    @IBOutlet weak var come_view2: UIView!
    @IBOutlet weak var come_view3: UIView!
    @IBOutlet weak var come_view4: UIView!
    
    @IBOutlet weak var come_viewHeight1: NSLayoutConstraint!
    @IBOutlet weak var come_viewHeight2: NSLayoutConstraint!
    @IBOutlet weak var come_viewHeight3: NSLayoutConstraint!
    @IBOutlet weak var come_viewHeight4: NSLayoutConstraint!
    
    
    var resultHandler: ((String) -> Void)?
    var voiceSetHandler: (() -> Void)?
    var closeHandler: (() -> Void)?
    
    var imageView: UIImageView!
    var classView = YuYinClassView()
    var elevtCard = ElevtCardView()
    var speechTask: MySpeedsTask?
    
    var AidaString: String = ""
    var messages: [[String: String]] = NSMutableArray() as! [[String: String]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(speakingValueNotification(_:)), name: NSNotification.Name("SpeakingValueNotificationNotification"), object: nil)
        

        classView = UINib(nibName: "YuYinClassView", bundle: nil).instantiate(withOwner: self, options: nil).first as! YuYinClassView
        classView.dataSource = self
        classView.alpha = 0.0
        self.view.addSubview(classView)
        self.classView.frame = CGRect(x: 0, y: -400, width: self.view.frame.size.width, height: 397)
        
        
        elevtCard = UINib(nibName: "ElevtCardView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ElevtCardView
        elevtCard.alpha = 0.0
        elevtCard.dataSource = self
        view.addSubview(elevtCard)
        elevtCard.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        MySpeeds.shared.stopPlay(false)
        self.animationImage.image = UIImage(named: "YY处理中")

        self.zoomIn()
        
        self.speechTask = MySpeedsTask( isDetectionEnabled: true)

        self.speechTask?.decibelScaleHandler = { [weak self] scale in
            guard let self = self else { return }
            self
            print("播放中……\(scale)")

        }

        self.speechTask?.resultHandler = { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 {
                self.stopInterfaceStyleConfiguration()
            }else {
//                self.resultHandler?(text)
                self.sendMessage(message: text)
                print(text)
                self.thinkingInterfaceStyleConfiguration()
            }
        }
        
        self.listeningStart()
        rotateImage()
        
        if let image_name = UserDefaults.standard.object(forKey: "voiceImg") as? String, image_name.count > 0 {
            Icon.image = UIImage(named: image_name)
        }
        
        if let voice_name = UserDefaults.standard.object(forKey: "voice_name") as? String, voice_name.count > 0 {
            label.text = voice_name
        }
        
    }
    
    @objc func speakingValueNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let decibelValue = userInfo["SpeakValue"] as? Float {
                
                let match: [Int] = [1, 2, 3, 4]
                if let randomView = match.randomElement() {
                    startVioceAnimating(index: randomView, scale: decibelValue)
                }
            }
        }
      
    }
    
    func startVioceAnimating( index: Int, scale: Float) {

        DispatchQueue.main.async {[weak self] in
            guard self != nil else { return }

            UIView.animate(withDuration: 0.3, animations: {
                self?.come_viewHeight1.constant = 68
                self?.come_viewHeight2.constant = 68
                self?.come_viewHeight3.constant = 68
                self?.come_viewHeight4.constant = 68
                
                if index == 1 {
                    self?.come_viewHeight1.constant = CGFloat(scale*68)
                }else if index == 2 {
                    self?.come_viewHeight2.constant = CGFloat(scale*68)
                }else if index == 3 {
                    self?.come_viewHeight3.constant = CGFloat(scale*68)
                }else if index == 4 {
                    self?.come_viewHeight4.constant = CGFloat(scale*68)
                }

            })
        }

    }

    @IBAction func choose(_ sender: UIButton) {
        classView.alpha = 1.0
        UIView.animate(withDuration: 0.31) {[self] in
            self.classView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 397)
        }
        
        stopInterfaceStyleConfiguration()
        speechTask?.cancelRecording()
//        speechTask = nil
    }
    
    @IBAction func back(_ sender: Any) {
        
        stopInterfaceStyleConfiguration()
        speechTask?.cancelRecording()
        speechTask = nil
        MySocket.shared.disconnect()
        self.dismiss(animated: true){
            self.closeHandler?()
        }
        
    }
    
    
    // 开始录音
    func listeningStart() {
        
        if isChatPermis() == false {
            self.elevtCard.showCardView()
            
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            guard let self = self else { return }
            
            self.speechTask?.startRecording()
            
            UIView.animate(withDuration: 0.6, animations: {[weak self] in
                guard let self = self else { return }
                self.listenView.isHidden = false
                self.handleView.isHidden = true
                self.speakView.isHidden = true
                self.statuslabel.text = "正在听取中"
            })
        }
    }
    
    
    //放大
    func zoomIn() {
        UIView.animate(withDuration: 0.81) {
            self.listenImage.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            self.zoomOut()
        }
    }
      
    //缩小
    func zoomOut() {
        UIView.animate(withDuration: 0.81) {
            self.listenImage.transform = .identity
        } completion: { _ in
            self.zoomIn()
        }
    }
    
    //旋转
    func rotateImage() {
        let list = "transform.rotation.z"
        let line = CABasicAnimation(keyPath: list)
        line.fillMode = CAMediaTimingFillMode.forwards
        line.isRemovedOnCompletion = false
        line.fromValue = NSNumber(value: 0)
        line.toValue = NSNumber(value: 2 * Double.pi)
        line.duration = 3.1

        let result = CAAnimationGroup()
        result.duration = 1.9
        result.repeatCount = Float.infinity
        result.animations = [line]
        result.fillMode = CAMediaTimingFillMode.forwards
        result.isRemovedOnCompletion = false
        self.animationImage.layer.add(result, forKey: "group")
        self.smallImage.layer.add(result, forKey: "group")
        
    }
    
    func stopInterfaceStyleConfiguration() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                guard let self = self else { return }

                self.statuslabel.text = ""
            })
        }
            
        self.speechTask?.cancelRecording()
        MySpeeds.shared.stopPlay(false)

    }

    
    func thinkingInterfaceStyleConfiguration() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                guard let self = self else { return }
                
                self.handleView.isHidden = false
                self.listenView.isHidden = true
                self.speakView.isHidden = true
                self.statuslabel.text = "正在处理中"
                
                
            })
        }
    }
    
    func answerInterfaceStyleConfiguration() {

        DispatchQueue.main.async {[weak self] in
            
            guard let self = self else { return }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                guard let self = self else { return }
                self.handleView.isHidden = true
                self.listenView.isHidden = true
                self.speakView.isHidden = false
                self.statuslabel.text = "正在讲话中"
            })
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    
    
    func sendMessage(message: String) {
        
        let timeStr = String(Int(Date().timeIntervalSince1970)*1000)
        MySocket.shared.connect(scoketlink: "\(WebUrl)\(timeStr)")
        MySocket.shared.connectSuccessCallBlock = { [self] in
            messageRequest(verity: timeStr, content: message, typeId: "")
        }
        
        MySocket.shared.connectFailedCallBlock = { _ in
            
        }
        
        AidaString = ""
        let dic = ["like":"MeQ","content":message]
        messages.append(dic)
        
        let object = ["like":"AIda","content":"\(AidaString)"]
        messages.append(object)
        
        
        MySocket.shared.didReceiveMessageCallBlock = { [self] message in
            if message.elementsEqual("DONE") {
                if let free = UserDefaults.standard.object(forKey: "free") as? Int {
                    UserDefaults.standard.set(free+1, forKey: "free")
                    
                    if free == 1 {
                        self.perform(#selector(openMark), with: nil, afterDelay: 2.81)
                    }
                }
                
                MySpeeds.shared.startPlay(message: AidaString) { AlisPlayStatus in
                    DispatchQueue.main.async { [self] in
                        switch AlisPlayStatus {
                            case .start:
                            self.answerInterfaceStyleConfiguration()
                            case .end:
                            self.listeningStart()
                        }
                    }
                }
                
            }
            else {
                self.collateSocketMessage(message: message)
            }
        }
    }
    
    @objc func openMark() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func collateSocketMessage(message: String) {
        AidaString = AidaString + message
        let dic = ["like":"AIda","content":"\(AidaString)"]
        if AidaString.elementsEqual(message) && message.count == 0 {
            return
        }
        messages[messages.count-1] = dic
        
        UserDefaults.standard.set(messages, forKey: "chat")
        
    }

}

extension YYloadingViewController: YuYinClassViewDataSource {
    func yuYinClassViewConfirm(imageName: String, yyName: String) {
        label.text = yyName
        Icon.image = UIImage(named: imageName)
        
        UIView.animate(withDuration: 0.31) {[self] in
            self.classView.frame = CGRect(x: 0, y: -400, width: self.view.frame.size.width, height: 397)
        }completion: { _ in
            self.classView.alpha = 0.0
            self.voiceSetHandler?()
        }
        
        listeningStart()
    }
}

extension YYloadingViewController: ElevtCardViewDataSource {
    func elevtCardViewPresent() {
        let elevtVC = ElevtViewController()
        elevtVC.modalPresentationStyle = .fullScreen
        self.present(elevtVC, animated: true)
    }
}
