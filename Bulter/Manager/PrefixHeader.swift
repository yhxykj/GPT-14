//
//  PrefixHeader.swift
//  Bulter
//
//  Created by JJK on 2024/3/21.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

let AppUrl = "https://sunjichang.top/api"
let WebUrl = "wss://sunjichang.top/websocket/"
let AppType = "14"

let keyWindow = UIApplication.shared.keyWindow
let Screen_height = UIScreen.main.bounds.size.height

struct KeyConfiguration {
    static let serviceName = "accountKey_"
}

func getAccountNumberIdentifier() -> String? {

    if let account_number = KeychainWrapper.standard.string(forKey: KeyConfiguration.serviceName) {
        return account_number
    }
    
    guard let UUID = UIDevice.current.identifierForVendor?.uuidString else {
        return nil
    }
    
    do {
        KeychainWrapper.standard.set(UUID, forKey: KeyConfiguration.serviceName)
        return UUID
    }
    
}
