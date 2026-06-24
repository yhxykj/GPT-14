//
//  MyResponse.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit
import SVProgressHUD

struct AppLogin: Codable {

    let msg: String?
    let code: Int?
    let data: [String: String]?
}

func mineLogin(phone: String, verity: String, Prefix:(() -> Void)? = nil) {
    
    var param = [String: Any]()
    param["phonenumber"] = phone
    param["smsCode"] = verity
    param["type"] = AppType
    
    SVProgressHUD.show()
    NetAlamofire.shared.post(urlSuffix: "/app/sms/smsCode/login", body: param) { (result: Result<AppLogin, NetworkError>) in
        switch result {
            case .success(let model):
                
            if model.code == 200 {

                SVProgressHUD.showSuccess(withStatus: "登录成功")
                let animation: String = model.data!["token"]!
                UserDefaults.standard.set(animation, forKey: "AccountToken")
                
                if let window = UIApplication.shared.delegate?.window {
                    window?.rootViewController =  UINavigationController(rootViewController: HomeViewController())
                }
            }else {
                SVProgressHUD.showError(withStatus: model.msg)
            }
                break
            case .failure(_):
                
                SVProgressHUD.showError(withStatus: "接口请求错误");
                break
        }
    }
}


struct AppMineInfo: Codable {

    let msg: String?
    let code: Int?
    let data: mineModel?
}

struct mineModel: Codable {

    let vipLabel: String?
    let vipStatus: String?
    let id: String?
    let vipExpireTime: String?
    let imgNum: Int?
    let avatar: String?
    let nickname: String?
    let wx: String?
}

func mineInfo(Prefix:(() -> Void)? = nil) {
    
    NetAlamofire.shared.post(urlSuffix: "/app/user/getCurrentInfo", body: [String: Any]()) { (result: Result<AppMineInfo, NetworkError>) in
        switch result {
        case.success(let model):
            
            print(model.data)
            if model.code == 200 {
                UserDefaults.standard.set(model.data?.vipStatus, forKey: "VIP")
                UserDefaults.standard.set(model.data?.vipExpireTime, forKey: "Time")
                UserDefaults.standard.set(model.data?.nickname, forKey: "name")
                
                mineFreeNumber()
            }
            else if (model.code == 401) {
                NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
            }
            else {
                
            }
            
        case.failure(_):
            SVProgressHUD.showError(withStatus: "接口请求错误");
            
            break
        }
    }
    
}


struct AppOther: Codable {

    let msg: String?
    let code: Int?
}

func messageRequest(verity: String, content: String, typeId: String, Prefix:(() -> Void)? = nil) {
    var param = [String: Any]()
    param["prompt"] = content
    param["uid"] = verity
    param["aiTypeId"] = typeId
    param["modelType"] = 0
    param["modelId"] = "2"
    
    NetAlamofire.shared.post(urlSuffix: "/ai/aiChat", body: param) { (result: Result<AppOther, NetworkError>) in
        
        switch result {
            case .success(let model):
                
            if model.code == 200 {

            }else {
                SVProgressHUD.showError(withStatus: model.msg)
            }
                break
            case .failure(_):
            
                SVProgressHUD.showError(withStatus: "接口请求错误");
                break
        }
        
    }
}

struct AppAiSketch: Codable {

    let msg: String?
    let code: Int?
    let data: String?
}

struct AppFindImg: Codable {

    let msg: String?
    let code: Int?
    let data: AppFindImgData?
}

struct AppFindImgData: Codable {
    
    let prompt: String?
    let imgUrl: String?
    let taskType: String?
    let id: String?
    let userId: String?
    let imgUrls: [String]?
    let imgTaskId: String?
    let resultConfig: Int?
    let taskParameter: String?
    let sum: Int?
}



struct AppChuanNew: Codable {

    let msg: String?
    let code: Int?
    let data: [AppChuanNewHeader]?
}

struct AppChuanNewHeader: Codable {

    let dictLabel: String?
    let dictValue: String?
    
}

struct AppChuanNewItems: Codable {

    let msg: String?
    let code: Int?
    let rows: [AppChuanNewItemRows]?
}

struct AppChuanNewItemRows: Codable {

    let aiName: String?
    let createType: String?
    let headUrl: String?
    let id: String?
    let aiBrief: String?
    let systemType: Int?
    let aiType: Int?
    let aiDetails: String?
    let aiTypeName: String?
    
}


struct AppVoicePlay: Codable {

    let msg: String?
    let code: Int?
    let data: String?
}

struct AppVipMeal: Codable {

    let msg: String?
    let code: Int?
    let data: [AppVipItemRows]?
}

struct AppVipItemRows: Codable {
    let amount: String?
    let amountDescript: String?
    let descript: String?
    let id: String?
    let iosId: String?
    let mealValue: Int?
    let sort: Int?
    let status: String?
    let valueDescript: String?
    let systemType: String?
    let type: String?
    let remark: String?
    let region: String?
}

func isChatPermis() -> Bool {
    
    if let vipValue = UserDefaults.standard.string(forKey: "VIP"), vipValue == "1" {

        return true
        
    } else {
        
        if let free = UserDefaults.standard.object(forKey: "free") as? Int {
      
            if let count = UserDefaults.standard.object(forKey: "count") as? Int {
//                UserDefaults.standard.set(free+1, forKey: "free")
                if free > count {
                    return false
                }
                
                return true
            }
        }
        else {
            UserDefaults.standard.set(1, forKey: "free")
        }
    }
    
    
    return true
}


func mineFreeNumber() {
    NetAlamofire.shared.normalPost(urlSuffix: "/app/getSum") { result in
        
        switch result {
        case.success(let model):
            
            if let obj = model as? NSDictionary, let code = obj["code"] as? Int {
                if code == 200 {
                    
                    if let count = obj["data"] as? String {
                        UserDefaults.standard.set(Int(count), forKey: "count")
                    }
                    
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

