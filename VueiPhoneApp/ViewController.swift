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
    
    var reqw: String?
    @IBOutlet weak var webView: WebView!
    
    var connectivity = ThirdModuleConnectivity.shared

    @IBAction func text(_ sender: Any) {
        if let reqw = reqw {
            self.webView.loadUrl(string: reqw)
        }
//        self.executeH5Function(functionName: "nativeObj.shareEnd", params: ["123456", "\"asdfghjh\""]) { (result: Any?, err: Error?) in
//            print("result:\(String(describing: result)) error:\(String(describing: err))")
//        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.webVc = self
        
        // UI 设置
        webView.scrollView.bounces = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        //itms-services://?action=download-manifest&url=https://download.fir.im/apps/58e46888ca87a84271000102/install?download_token=fb50d8c0d7ffebb275b1a0ce98bb5912&release_id=58e46892ca87a8755e000412
        
//        self.reqw = "http://172.16.47.9:3000/Cater/mobileh6/index.html#/phome"
        self.reqw = "http://wect.haidilao.com/Cater/mobileh6/index.html#/phome"
//        self.reqw = "http://172.16.47.175/Cater/web/lostandfound/page/add.jsp"
        webView.loadUrl(string: self.reqw!)
        
        // MARK: 注册 H5用 方法
        // window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.login_QQ.rawValue)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.login_WeChat.rawValue)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.share_QQ_Web.rawValue)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.share_WeChat_Web.rawValue)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.pay_Alipay.rawValue)
        webView.configuration.userContentController.add(self.connectivity, name: RespH5Type.pay_WeChat.rawValue)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func executeH5Function(functionName: String, params: [String], completionHandler: ((Any?, Error?) -> Swift.Void)? = nil) {
        
        let jsParams = params.joined(separator: ", ")

        let javaScriptString = "\(functionName)(\(jsParams))"
        
        print("----- \n 调用H5方法：\(javaScriptString)")
        self.webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}


// MARK:- WKUIDelegate
extension ViewController: WKUIDelegate {
    
    /// 网页 Alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "好的", style: UIAlertActionStyle.cancel) { (_) in
            completionHandler()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 网页 确定弹框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (_) in
            completionHandler(false)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// 网页 输入框提示
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (_) in}
        let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            completionHandler(alert.textFields?.last?.text)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: WKNavigationDelegate {
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        let req = navigationAction.request
//        reqw = navigationAction.request
//        reqw?.url = URL(string: "https://download.fir.im/apps/58e46888ca87a84271000102/install?download_token=fb50d8c0d7ffebb275b1a0ce98bb5912&release_id=58e46892ca87a8755e000412")
//        print("\(req)")
//        decisionHandler(.allow)
//    }
}


