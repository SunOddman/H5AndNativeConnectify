//
//  ViewController.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/2.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import UIKit
import WebKit




// MARK:-

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WebView!
    
    var connectivity = ThirdModuleConnectivity()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.webVc = self
        
        // UI 设置
        webView.scrollView.bounces = false
        webView.uiDelegate = self
//        webView.load(URLRequest(url: URL(string: "https://www.baidu.com/")!))
        webView.loadUrl(string: "https://www.baidu.com/")
        webView.configuration.userContentController.add(self.connectivity, name: "closeMe")
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func executeH5Function(functionName: String, params: [String]?, completionHandler: ((Any?, Error?) -> Swift.Void)? = nil) {
        
        let jsParams = params?.joined(separator: ", ") ?? ""
        
        let javaScriptString = "\(functionName)(\(jsParams))"
        
        self.webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}


// MARK:- WKUIDelegate
extension ViewController: WKUIDelegate {
    
}



