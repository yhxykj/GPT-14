//
//  MyShowImage.swift
//  Bulter
//
//  Created by JJK on 2024/4/16.
//

import UIKit
import YBImageBrowser

class MyShowImage: NSObject {
    
    static let show = MyShowImage()
    
    func action_displayImages(_ images: [String], index: Int, sender: UIView) {
        if images.isEmpty {
            return
        }
        
        var displayIndex = index
        if displayIndex < 0 || displayIndex >= images.count {
            displayIndex = 0
        }
        
        var datas: [YBIBImageData] = []
        images.enumerated().forEach { (idx, obj) in
            let data = YBIBImageData()
            data.projectiveView = sender

            if let image = obj as? UIImage {
                data.image = {
                    return image
                }
            } else if let urlString = obj as? String {
                if let URLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                    let imageURL = URL(string: URLString) {
                    data.imageURL = imageURL
                }
            }

            datas.append(data)
        }

        let browser = YBImageBrowser()
        browser.dataSourceArray = datas
        browser.currentPage = displayIndex
        browser.show()
    }
}
