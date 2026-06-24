//
//  ChuangDetailsView.swift
//  Bulter
//
//  Created by JJK on 2024/4/11.
//

import UIKit

protocol ChuangDetailsViewDataSource: AnyObject {
    func chuangDetailsViewContent(content: String)
}

class ChuangDetailsView: UIView {
    
    weak var dataSource: ChuangDetailsViewDataSource?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var datas = NSArray()
    var s_row = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ChuangDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    @IBAction func close(_ sender: Any) {
        UIView.animate(withDuration: 0.31, animations: {
            self.frame = CGRect(x: 0, y: self.frame.size.height+10, width: self.frame.size.width, height: self.frame.size.height)
        })
    }
    
    func selectItems(title: String, data: [String: Any]?) {
        label.text = title
        
        if let content = data?["content"] as? [String] {
                // 在这里使用 content 参数进行操作
                print(content)
            datas = content as NSArray
            self.tableView.reloadData()
        }
        
    }
    
}

extension ChuangDetailsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChuangDetailsTableViewCell
        cell.selectionStyle = .none
        
        if let content = datas[indexPath.row] as? String {
            cell.label.text = content
        }
        
        cell.s_icon.image = UIImage(named: "未选中")
        if s_row == indexPath.row {
            cell.s_icon.image = UIImage(named: "选中")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        s_row = indexPath.row
        self.tableView.reloadData()
        
        if let content = datas[indexPath.row] as? String {
            self.dataSource?.chuangDetailsViewContent(content: content)
        }
    }
}
