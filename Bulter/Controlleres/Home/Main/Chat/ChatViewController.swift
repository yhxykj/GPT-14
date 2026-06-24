//
//  ChatViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit
import ZKProgressHUD

class ChatViewController: UIViewController {

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textTF: UITextView!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var nav_label: UILabel!
    @IBOutlet weak var numberlabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navgationHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    var isChat = false
    var AidaString: String = ""
    var shuYu: String = ""
    var typeID: String = ""
    var aiName: String = ""
    var messages: [[String: String]] = NSMutableArray() as! [[String: String]]
    var elevtCard = ElevtCardView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.mineChatlishiMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MySpeeds.shared.stopPlay()
        MySocket.shared.disconnect()
        messageSuccess()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: NSNotification.Name("UpdateTableViewNotificationName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFreeCount), name: NSNotification.Name("updateFreeCountNotificationName"), object: nil)
        
        
        
        elevtCard = UINib(nibName: "ElevtCardView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ElevtCardView
        elevtCard.alpha = 0.0
        elevtCard.dataSource = self
        
        if (self.isChat == true) {
            self.navigationController?.isNavigationBarHidden = false
            self.view.addSubview(elevtCard)
        }
        else {
            keyWindow?.addSubview(elevtCard)
        }
        elevtCard.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.tableView.register(UINib(nibName: "ChatHeaderViewCell", bundle: nibBundle), forCellReuseIdentifier: "header")
        self.tableView.register(UINib(nibName: "MeQTableViewCell", bundle: nibBundle), forCellReuseIdentifier: "MeQ")
        self.tableView.register(UINib(nibName: "AIdaTableViewCell", bundle: nibBundle), forCellReuseIdentifier: "AIda")
        
        self.mineChatlishiMessage()
        
    }
    
    @objc func updateTableView() {
        self.messages.removeAll()
        mineChatlishiMessage()
    }
    
    func mineChatlishiMessage() {
        if (self.isChat == false) {
            self.navigationView.isHidden = true
            self.navgationHeight.constant = 0;
            let lishi = UserDefaults.standard.object(forKey: "chat")
            if lishi != nil {
                self.messages = UserDefaults.standard.object(forKey: "chat") as! [[String: String]]
            }
        }
        else {
            updateFreeCount()
            self.backImage.isHidden = false
            self.navigationView.isHidden = false
            self.nav_label.text = self.aiName
            let lishi = UserDefaults.standard.object(forKey: self.typeID)
            if lishi != nil {
                self.messages = UserDefaults.standard.object(forKey: self.typeID) as! [[String: String]]
            }
        }
        self.tableView.reloadData()
        self.scrollToTheEndLastBottom()
    }
    
    @objc func updateFreeCount() {
        if let vipValue = UserDefaults.standard.string(forKey: "VIP"), vipValue == "1" {
            numberView.isHidden = true
        }
        else {
            numberView.isHidden = false
        }
        
        if isChatPermis() == false {
            numberlabel.text = "免费次数已用完"
        }
        else {
            if let free = UserDefaults.standard.object(forKey: "free") as? Int {
                if let count = UserDefaults.standard.object(forKey: "count") as? Int {
                    
                    if free > count {
                        numberlabel.text = "免费次数已用完"
                        return
                    }

                    numberlabel.text = "剩余免费问答次数：\(count-free)"
                }
            }
        }
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        
        if UserDefaults.standard.object(forKey: "AccountToken") == nil {
           
            NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
            return
            
        }
        
        if textTF.text.count == 0 {
            ZKProgressHUD.showError("内容不能为空")
            return
        }
        self.view.endEditing(true)
        
        if isChatPermis() == false {
            self.elevtCard.showCardView()
            
            numberlabel.text = "免费次数已用完"
            
            return
        }
        else {
            if let free = UserDefaults.standard.object(forKey: "free") as? Int {
                if let count = UserDefaults.standard.object(forKey: "count") as? Int {
                    
                    if free > count {
                        numberlabel.text = "免费次数已用完"
                    }
                    else {
                        numberlabel.text = "剩余免费问答次数：\(count-free)"
                    }
                }
            }
        }
        
        self.messageLoading()
        
        let timeStr = String(Int(Date().timeIntervalSince1970)*1000)
        MySocket.shared.connect(scoketlink: "\(WebUrl)\(timeStr)")
        MySocket.shared.connectSuccessCallBlock = { [self] in
            messageRequest(verity: timeStr, content: textTF.text, typeId: self.typeID)
            self.textTF.text = ""
        }
        
        MySocket.shared.connectFailedCallBlock = { _ in
            self.messageSuccess()
        }
        
        AidaString = ""
        let dic = ["like":"MeQ","content":"\(textTF.text!)"]
        messages.append(dic)
        
        let object = ["like":"AIda","content":"\(AidaString)"]
        messages.append(object)
        
        self.tableView.reloadData()
        self.scrollToTheEndLastBottom()
        
        MySocket.shared.didReceiveMessageCallBlock = { [self] message in
            if message.elementsEqual("DONE") {
                if let free = UserDefaults.standard.object(forKey: "free") as? Int {
                    UserDefaults.standard.set(free+1, forKey: "free")
                    
                    if free == 1 {
                        self.perform(#selector(openMark), with: nil, afterDelay: 2.81)
                    }
                }
                self.messageSuccess()
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
        self.tableView.reloadData()
        
        if isChat == false {
            UserDefaults.standard.set(messages, forKey: "chat")
        }
        else {
            UserDefaults.standard.set(messages, forKey: self.typeID)
        }
        
        self.scrollToTheEndLastBottom()
    }
    
    
    func messageSuccess() {
        self.messageBtn.isEnabled = true
        self.messageBtn.alpha = 1.0;
    }
    
    func messageLoading() {
        self.messageBtn.isEnabled = false
        self.messageBtn.alpha = 0.3;
    }
    
    func scrollToTheEndLastBottom() {
        
        if isChat == true {
            let items = self.tableView.numberOfRows(inSection: 0)
            if items > 0 {
                let indexPath = IndexPath(row: items - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        else {
            let items = self.tableView.numberOfRows(inSection: 1)
            if items > 0 {
                let indexPath = IndexPath(row: items - 1, section: 1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
    }

    
    func updateTextViewHeight() {
        let fixedWidth = textTF.frame.size.width
        let newSize = textTF.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if newSize.height < 48 {
            textViewHeightConstraint.constant = 78
        }
        else {
            textViewHeightConstraint.constant = newSize.height + 50
        }
        
        view.layoutIfNeeded()
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isChat == true) {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.isChat == true) {
            return self.messages.count
        }
        
        if section == 0 {
            return 1
        }
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.isChat == true) {
            let object = self.messages[indexPath.row]
            let like = object["like"]!
            if like.elementsEqual("MeQ") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeQ") as! MeQTableViewCell
                cell.backgroundColor = .clear
                cell.meQlabel.text = object["content"]
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AIda") as! AIdaTableViewCell
                cell.backgroundColor = UIColor(red: 224/255.0, green: 244/255.0, blue: 231/255.0, alpha: 1.0)
                cell.aidAlabel.text = object["content"]
                cell.dataSource = self
                
                cell.gifImage.isHidden = true
                if cell.aidAlabel.text?.count == 0 {
                    cell.gifImage.isHidden = false
                }
                
                return cell
            }
        }
        
        if indexPath.section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "header") as! ChatHeaderViewCell
            header.backgroundColor = .clear
            header.dataSource = self
            return header
        }
        else {
            let object = self.messages[indexPath.row]
            let like = object["like"]!
            if like.elementsEqual("MeQ") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeQ") as! MeQTableViewCell
                cell.backgroundColor = .clear
                cell.meQlabel.text = object["content"]
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AIda") as! AIdaTableViewCell
                cell.backgroundColor = UIColor(red: 224/255.0, green: 244/255.0, blue: 231/255.0, alpha: 1.0)
                cell.aidAlabel.text = object["content"]
                cell.dataSource = self
                
                cell.gifImage.isHidden = true
                if cell.aidAlabel.text?.count == 0 {
                    cell.gifImage.isHidden = false
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
}

extension ChatViewController: ChatHeaderViewCellDataSource {
    
    func chatHeaderViewCellContent(QStr: String) {
        self.textTF.text = QStr
        print(QStr)
    }
}

extension ChatViewController: ElevtCardViewDataSource {
    func elevtCardViewPresent() {
        let elevtVC = ElevtViewController()
        elevtVC.modalPresentationStyle = .fullScreen
        self.present(elevtVC, animated: true)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}

extension ChatViewController: AIdaTableViewCellDataSource {
    func deleteAIdaTableViewCell(cell: AIdaTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            messages.remove(at: indexPath.row)
            
            if isChat == false {
                UserDefaults.standard.set(messages, forKey: "chat")
            }
            else {
                UserDefaults.standard.set(messages, forKey: self.typeID)
            }
            
            tableView.reloadData()
        }
    }
    
    func buttonplayVoiceAIdaTableViewCell(cell: AIdaTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let object = messages[indexPath.row]
            MySpeeds.shared.startPlay(message: object["content"]!) { AlisPlayStatus in
                DispatchQueue.main.async { [self] in
                    switch AlisPlayStatus {
                        case .start:
                        self.tableView.reloadData()
                        break
                        case .end:
                        self.tableView.reloadData()
                        break
                    }
                }
            }
        }
    }
}
