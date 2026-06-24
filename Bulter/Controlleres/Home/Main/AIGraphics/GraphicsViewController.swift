//
//  GraphicsViewController.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit
import SVProgressHUD
import ZKProgressHUD
import YYImage
import YYWebImage

class GraphicsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textTF: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    var photoId: String = ""
    var graphics: [[String: String]] = NSMutableArray() as! [[String: String]]
    var elevtCard = ElevtCardView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: NSNotification.Name("UpdateTableViewNotificationName"), object: nil)
        
        elevtCard = UINib(nibName: "ElevtCardView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ElevtCardView
        elevtCard.alpha = 0.0
        elevtCard.dataSource = self
        keyWindow?.addSubview(elevtCard)
        elevtCard.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }

        self.tableView.register(UINib(nibName: "GraphicsHeaderViewCell", bundle: nil), forCellReuseIdentifier: "header")
        self.tableView.register(UINib(nibName: "MeQTableViewCell", bundle: nil), forCellReuseIdentifier: "MeQ")
        self.tableView.register(UINib(nibName: "GraphicsTableViewCell", bundle: nil), forCellReuseIdentifier: "graphics")
        
        self.getGraphicsMessage()
    }
    
    @objc func updateTableView() {
        self.graphics.removeAll()
        getGraphicsMessage()
    }
    
    func getGraphicsMessage() {
        let lishi = UserDefaults.standard.object(forKey: "paint")
        if lishi != nil {
            self.graphics = UserDefaults.standard.object(forKey: "paint") as! [[String: String]]
        }
        
        self.tableView.reloadData()
        self.scrollToTheEndLastBottom()
    }
    
    @IBAction func send(_ sender: UIButton) {
        if textTF.text.count == 0 {
            ZKProgressHUD.showError("内容不能为空")
            return
        }
        
        if let vipValue = UserDefaults.standard.string(forKey: "VIP"), vipValue != "1" {
            self.elevtCard.showCardView()
            return
            
        }
        
        self.paintChatRequest(content: self.textTF.text)
        
        let dic = ["like":"MeQ","content":"\(textTF.text!)","status":"1"]
        graphics.append(dic)

        self.tableView.reloadData()
        self.sendBtn.isEnabled = false
        self.sendBtn.alpha = 0.3
        self.textTF.text = ""
        self.scrollToTheEndLastBottom()
    }
    
    
    
    func paintChatRequest(content: String, prefix:(() -> Void)? = nil) {
        var param = [String: Any]()
        param["sum"] = "1"
        param["prompt"] = content
        param["taskParameter"] = "1"
        param["resultConfig"] = "1"
        
        
        NetAlamofire.shared.post(urlSuffix: "/img/aiSketch", body: param) { (result: Result<AppAiSketch, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 500 {// 积分不足
                    self.sendBtn.isEnabled = true
                    self.sendBtn.alpha = 1.0
                    
                    SVProgressHUD.showError(withStatus: model.msg)
                    return
                    
                }
                else if model.code == 200 {
                    print("图片imageId\(model.data!)")
                    self.photoId = model.data!
                    
                    let object = ["like":"AIda","content":"","status":"0"]
                    self.graphics.append(object)
                    self.tableView.reloadData()
                    
                    self.queryPictureProgress()
                }
                else {
                    self.sendBtn.isEnabled = true
                    self.sendBtn.alpha = 1.0
                    SVProgressHUD.showError(withStatus: "绘画失败，请稍后重试")
                }
                
                break
            
            case.failure(_):
                self.sendBtn.isEnabled = true
                self.sendBtn.alpha = 1.0
                SVProgressHUD.showError(withStatus: "链接错误")
                break
            
            }
        }
    }

    @objc func queryPictureProgress() {
        var param = [String: Any]()
        param["taskId"] = self.photoId
       
        NetAlamofire.shared.post(urlSuffix: "/img/findImg", body: param) { (result: Result<AppFindImg, NetworkError>) in
            switch result {
            case.success(let model):
                
                if model.code == 200 {
                    
                    let header: AppFindImgData = model.data!
                    print(header)
                    if let taskTypeString = header.taskType, let taskTypeInt = Int(taskTypeString) {
                        if taskTypeInt == 2 {
                            if let images: [String] = header.imgUrls! as? [String], !images.isEmpty {
                                let imageUrl: String = images.first!
                                let object = ["like":"AIda","content":imageUrl,"status":"1"]
                                self.graphics[self.graphics.count-1] = object
                                UserDefaults.standard.set(self.graphics, forKey: "paint")
                            }
                            self.sendBtn.isEnabled = true
                            self.sendBtn.alpha = 1.0
                            
                            self.tableView.reloadData()
                        }
                        else {
                            self.queryPictureStatus()
                        }
                    }
            
                }
                else {
                    self.sendBtn.isEnabled = true
                    self.sendBtn.alpha = 1.0
                }
                
                break
                
            case.failure(_):
                
                break
            }
        }
        
    }
    
    @objc func queryPictureStatus() {
        self.perform(#selector(queryPictureProgress), with: nil, afterDelay: 4.81)
    }

    
    func scrollToTheEndLastBottom() {
        let items = self.tableView.numberOfRows(inSection: 1)
        if items > 0 {
            let indexPath = IndexPath(row: items - 1, section: 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func loadingGif() -> YYImage? {
        if let gifPath = Bundle.main.path(forResource: "loading", ofType: "gif"),
            let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
            let hengImage = YYImage(data: gifData) {

            return hengImage
        }
        return nil
    }
    

    func saveImageToPhotoAlbum(imageURL: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL),
               let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                SVProgressHUD.showSuccess(withStatus: "下载成功")
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

extension GraphicsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.graphics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! GraphicsHeaderViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.dataSource = self
            return cell
        }
        else if indexPath.section == 1 {
            let object = self.graphics[indexPath.row]
            let like = object["like"]!
           
            if like.elementsEqual("MeQ") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeQ") as! MeQTableViewCell
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.meQlabel.text = object["content"]
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "graphics") as! GraphicsTableViewCell
                cell.backgroundColor = UIColor(red: 224/255.0, green: 244/255.0, blue: 231/255.0, alpha: 1.0)
                cell.selectionStyle = .none
                cell.dataSource = self
                
                cell.picImage.image = nil
                if let status = object["status"], status.elementsEqual("1") {
                    if let url = object["content"] {
                        cell.picImage.layer.yy_setImage(with: URL(string: url), placeholder: UIImage())
                    }
                }
                else
                {
                    cell.picImage.image = loadingGif()
                }
                
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
}

extension GraphicsViewController: GraphicsHeaderViewCellDataSource {
    func defaultQuestionGraphicsHeaderViewCell(content: String) {
        textTF.text = content
    }
}


extension GraphicsViewController: GraphicsTableViewCellDataSource {
    func deleteGraphicsTableViewCell(cell: GraphicsTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        if self.graphics.count > 0 {
            if let row = indexPath?.row {
                let object = self.graphics[row]
                if let status = object["status"], status.elementsEqual("1") {
                    self.graphics.remove(at: row)
                    UserDefaults.standard.set(self.graphics, forKey: "paint")
                    self.tableView.reloadData()
                }
                else{
                    SVProgressHUD.showError(withStatus: "图片生成中，暂不支持删除")
                }
                
                
            }
            
        }
        
    }
    
    func saveImageGraphicsTableViewCell(cell: GraphicsTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        if let row = indexPath?.row {
            let object = self.graphics[row]
            if let url = object["content"], url.count > 0 {
                let imageURL = URL(string: url)
                self.saveImageToPhotoAlbum(imageURL: imageURL!)
                SVProgressHUD.showError(withStatus: "图片下载中……")
            }
            else{
                SVProgressHUD.showError(withStatus: "图片生成中，请等待……")
            }
        }
    }
    
    func tapImageGraphicsTableViewCell(cell: GraphicsTableViewCell) {
        var images: [String] = NSArray() as! [String]

        let indexPath = self.tableView.indexPath(for: cell)
        if let row = indexPath?.row {
            let object = self.graphics[row]
            if let url = object["content"], url.count > 0 {
                images = [url]
                MyShowImage.show.action_displayImages(images, index: row, sender: cell.picImage)
            }
            else {
                SVProgressHUD.showError(withStatus: "图片生成中，暂不支持预览")
            }
        }
    }
}

extension GraphicsViewController: ElevtCardViewDataSource {
    func elevtCardViewPresent() {
        let elevtVC = ElevtViewController()
        elevtVC.modalPresentationStyle = .fullScreen
        self.present(elevtVC, animated: true)
    }
}

extension GraphicsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}
