//
//  MySocket.swift
//  Bulter
//
//  Created by JJK on 2024/3/22.
//

import UIKit
import Starscream
import SocketRocket

class MySocket: NSObject {
    static let shared = MySocket()
    
    var webSocket: SRWebSocket?
    var connectFailedCallBlock: ((Error) -> Void)?
    var connectSuccessCallBlock: (() -> Void)?
    var didReceiveMessageCallBlock: ((String) -> Void)?
    
    func connect(scoketlink urlStr: String) {

        webSocket = SRWebSocket(url: NSURL(string: urlStr)! as URL)
        webSocket?.delegate = self
        webSocket?.open()
    }

    func disconnect() {
        webSocket?.close()
    }
    
}

extension MySocket: SRWebSocketDelegate {
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        print("WebSocket 连接成功")
        connectSuccessCallBlock?()
    }
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        print("WebSocket 连接失败")
        connectFailedCallBlock?(error)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        if let text = message as? String {
            didReceiveMessageCallBlock?(text)
            print("WebSocket消息：\(text)")
        }
    }
}
