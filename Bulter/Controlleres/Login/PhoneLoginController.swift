//
//  PhoneLoginController.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit
import ZKProgressHUD
import SVProgressHUD

class PhoneLoginController: UIViewController {

    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    @IBAction func getVerity(_ sender: UIButton) {
        if phone.text?.count != 11 {
            ZKProgressHUD.showError("输入正确的手机号")
            return
        }
        
        var body = [String: Any]()
        body["phonenumber"] = phone.text
        
        SVProgressHUD.show()
        NetAlamofire.shared.post(urlSuffix: "/app/sms/getcode", body: body) { (result: Result<AppLogin, NetworkError>) in
            switch result {
                case .success(let responseModel):
                    
                if responseModel.code == 200 {

                    SVProgressHUD.showSuccess(withStatus: "验证码发送成功")

                    }else {
                        SVProgressHUD.showError(withStatus: "验证码发送失败")
                    }
                    break
                case .failure(_):
                    
                    SVProgressHUD.showError(withStatus: "接口请求错误");
                    break
            }
        }
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        if phone.text?.count != 11 {
            ZKProgressHUD.showError("输入正确的手机号")
            return
        }
        if code.text?.count != 4 {
            ZKProgressHUD.showError("输入正确的验证码")
            return
        }
        
        mineLogin(phone: phone.text!, verity: code.text!)
    }
    
    
    
}
