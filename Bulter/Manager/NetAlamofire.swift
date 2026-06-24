//
//  NetAlamofire.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit
import Alamofire

enum NetworkError: Error {
    case unknown(String)
}

class NetAlamofire {
    static let shared: NetAlamofire = {
        let instance = NetAlamofire()
        return instance
    }()

    func post<Response: Codable>(_ isDebugLog: Bool = false,
                          urlSuffix: String,
                          body: [String: Any] = [:],
                          completionHandler: @escaping (Result<Response, NetworkError>) -> Void) {
        
        let urlString = "\(AppUrl)\(urlSuffix)"
        let AccountToken = UserDefaults.standard.object(forKey: "AccountToken") ?? "noToken"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AccountToken)",
            "Content-Type": "application/json",
            "userType": "app_user"
        ]
        
        var parameters: [String: Any] = body
        parameters["systemType"] = AppType
        
        print(parameters)
        
        if isDebugLog == false {
            
            AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseDecodable(of: Response.self) { response in
                
                switch response.result {
                    case .success(let value):
                        completionHandler(.success(value))
                    case .failure(let error):
                        print("接口\(urlSuffix)报错: \n\(error.localizedDescription)")
                        completionHandler(.failure(.unknown("接口\(urlSuffix)报错: \n\(error.localizedDescription)")))
                }
            }
        }
        else {


        }

    }
    
    
    func normalPost( urlSuffix: String,
                  body: [String: Any] = [:],
                  completionHandler: @escaping (Result<Any, NetworkError>) -> Void) {
    
        let urlString = "\(AppUrl)\(urlSuffix)"
        let AccountToken = UserDefaults.standard.object(forKey: "AccountToken") ?? "noToken"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AccountToken)",
            "Content-Type": "application/json",
            "userType": "app_user"
        ]
  
        var parameters: [String: Any] = body
        parameters["systemType"] = AppType

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                case .success(let data):
                    do {
                        let avatars = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let lines = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.json")
                        
                        try avatars.write(to: lines)
                        
                        if let jsonString = try? String(contentsOf: lines) {
                            print("——————\(urlSuffix)传入：\(parameters)")
                            print("——————\(urlSuffix)返回：\(jsonString)")
                            completionHandler(.success(data))
                        } else {
                            completionHandler(.failure(.unknown("无法读取 JSON 数据")))
                        }
                        try FileManager.default.removeItem(at: lines)
                    } catch {
                        completionHandler(.failure(.unknown("转换为 JSON 数据时出错：\(error)")))

                    }
                case .failure(let error):
                    completionHandler(.failure(.unknown(error.localizedDescription)))
            }
        }
    }
    
}

