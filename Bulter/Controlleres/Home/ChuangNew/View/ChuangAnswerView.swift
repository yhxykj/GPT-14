//
//  ChuangAnswerView.swift
//  Bulter
//
//  Created by JJK on 2024/4/11.
//

import UIKit
import ZKProgressHUD

class ChuangAnswerView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textTF: UITextView!
    @IBOutlet weak var messageBtn: UIButton!
    
    var AidaString: String = ""
    var typeID: String = ""
    var param: [String: Any] = [:]
    var messages: [[String: String]] = NSMutableArray() as! [[String: String]]
    
    override func awakeFromNib() {
        
        self.tableView.register(UINib(nibName: "MeQTableViewCell", bundle: nil), forCellReuseIdentifier: "MeQ")
        self.tableView.register(UINib(nibName: "AIdaTableViewCell", bundle: nil), forCellReuseIdentifier: "AIda")
        
        let lishi = UserDefaults.standard.object(forKey: typeID)
        if lishi != nil {
            self.messages = UserDefaults.standard.object(forKey: typeID) as! [[String: String]]
        }
        
        self.tableView.reloadData()
        self.scrollToTheEndLastBottom()
    }

    @IBAction func back(_ sender: Any) {
        UIView.animate(withDuration: 0.31, animations: {
            self.frame = CGRect(x: 0, y: self.frame.size.height+10, width: self.frame.size.width, height: self.frame.size.height)
        })
    }
    
    @IBAction func send(_ sender: Any) {
        if textTF.text.count == 0 {
            ZKProgressHUD.showError("内容不能为空")
            return
        }
        
        sendChatMessage()
        
    }
    
    func processParam(dict: [String: Any], msgStr: String, homeId: String) {
            
        typeID = homeId
        param = dict
        
        self.textTF.text = msgStr
        
        sendChatMessage()
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
    
    
    func sendChatMessage() {
        
        self.messageLoading()
        
        let timeStr = String(Int(Date().timeIntervalSince1970)*1000)
        MySocket.shared.connect(scoketlink: "\(WebUrl)\(timeStr)")
        MySocket.shared.connectSuccessCallBlock = { [self] in
            
            let content = dictionaryToJson(targetObject: param)
            messageRequest(verity: timeStr, content: content!, typeId: self.typeID)
            self.textTF.text = ""
        }
        
        MySocket.shared.connectFailedCallBlock = { _ in
            self.messageSuccess()
        }
        
        AidaString = ""
        let dic = ["like":"MeQ","content":"\(self.textTF.text!)"]
        messages.append(dic)
        
        let object = ["like":"AIda","content":"\(AidaString)"]
        messages.append(object)
        
        self.tableView.reloadData()
        
        MySocket.shared.didReceiveMessageCallBlock = { [self] message in
            if message.elementsEqual("DONE") {
                self.messageSuccess()
            }
            else {
                self.collateSocketMessage(message: message)
            }
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
        
        UserDefaults.standard.set(messages, forKey: self.typeID)
        
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
        let items = self.tableView.numberOfRows(inSection: 0)
        if items > 0 {
            let indexPath = IndexPath(row: items - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}


extension ChuangAnswerView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            return cell
        }
        return UITableViewCell()
    }
    
}
