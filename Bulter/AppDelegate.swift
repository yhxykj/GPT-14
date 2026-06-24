//
//  AppDelegate.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import UIKit
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        detectNetworkStatus()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        MySpeeds.shared.stopPlay(false)
    }
    
    func detectNetworkStatus()  {
        let length: NetworkReachabilityManager?
        length = NetworkReachabilityManager.default
        
        length?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable:
     
                print("网络不可达")

            case .reachable(let connectionType):

                switch connectionType {
                case .ethernetOrWiFi:

                    print("Wi-Fi连接")
                    NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
                case .cellular:
                    // 蜂窝数据连接
                    print("蜂窝数据连接")
                    NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
                }
            case .unknown:
                break
            }
        })
  
    }
    

}

