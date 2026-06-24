//
//  WKWebViewController.swift
//  Bulter
//
//  Created by JJK on 2024/4/16.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var gressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    var webUrl: String = ""
    var titleStr: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titlelabel.text = titleStr

        webView.navigationDelegate = self
        view.addSubview(webView)
        
        openWebView(url: webUrl)
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func openWebView(url: String) {
        let request = URL(string: url)
        let myRequest = URLRequest(url: request!)
        webView.load(myRequest)
    }

}

extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        gressView.isHidden = false
        gressView.setProgress(0, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.gressView.alpha = 1
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.gressView.alpha = 0
        }completion: { (_) in
            self.gressView.isHidden = true
            self.gressView.setProgress(0, animated: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.gressView.alpha = 0
        }completion: { (_) in
            self.gressView.isHidden = true
            self.gressView.setProgress(0, animated: false)
        }
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 在页面开始加载的时候，设置加载进度值
        gressView.setProgress(Float(webView.estimatedProgress), animated: true)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 停止加载时，隐藏进度条并重置加载进度值
        UIView.animate(withDuration: 0.2, delay: 0.2) {
            self.gressView.alpha = 0.0
        } completion: { (_) in
            self.gressView.isHidden = true
            self.gressView.setProgress(0, animated: false)
        }
    }
    
}

