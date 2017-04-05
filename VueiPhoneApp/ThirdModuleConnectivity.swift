//
//  ThirdModuleConnectivity.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/2.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import UIKit
import WebKit

//// 腾讯QQ
//let tencentAppId = "1106080432"
//let tencentAppKey = "cV3wAzH1GDuXVKjj"
//
//// 微信
//let weChatAppId = ""


// MARK:-

/// alert等级
enum MessageLevelType: Int {
    case log = -1
    case success = 0
    case warning = 1
    case alert = 2
    case failed = 3
    case error = 4
}

/// 调用H5方法列表
enum ReqH5Type: String {
    case paySuccess = "paySuccess"
    case otherLoginSuccess = "otherLoginSuccess"
    case shareSuccess = "shareSuccess"
    case nativeError = "nativeError"
    case addCard = "addCard"
    case chooseCard = "chooseCard"
}

/// H5调用本地方法列表
enum RespH5Type: String {
    case login_QQ = "login_QQ"
    case login_WeChat = "login_WeChat"
    case share_QQ_Web = "share_QQ_Web"
    case share_WeChat_Web = "share_WeChat_Web"
    case pay_Alipay = "pay_Alipay"
    case pay_WeChat = "pay_WeChat"
}

// MARK:-
class ThirdModuleConnectivity: NSObject {
    
    var tencentOauth: TencentOAuth?
    
    var webVc: ViewController {
        get {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            return delegate.webVc!
        }
    }
    
    
    func messageHappend(reqType: ReqH5Type, message: String, messageLevel: MessageLevelType, params: [String: String]?) {
        print("----- \n messageHappend: \(messageLevel):\n\t \(message)")
        
        // TODO: 给H5发送消息
        let reqParams = ["\(message)", "\(messageLevel)", "\(params ?? [:])"]
        
        webVc.executeH5Function(functionName: reqType.rawValue,
                                params: reqParams) { (result: Any?, error: Error?) in
            print("----- \n 调用H5结果：\(String(describing: result)) \n 错误：\(String(describing: error))")
        }
    }
    
}

// MARK:-
extension ThirdModuleConnectivity: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        messageHappend(reqType: .nativeError, message: "----- \n 调H5调用本地方法：【\(message.name)】，参数：【\(message.body)】", messageLevel: .log, params: nil)
        
        let params = message.body as? [String : String] ?? [:]
        
        // MARK: QQ登录
        func qqLogin() {
            let params = message.body as? [String: Any] ?? [:]
            guard
                let appId = params["appId"] as? String,
                let permission = params["permission"] as? [String]
            else {
                messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                return
            }
            self.tencentLogin(appId: appId, permission: permission)
        }
        
        // MARK: 微信登录
        func wxLogin() {
            guard
                let appId = params["appId"],
                let scope = params["scope"],
                let state = params["state"]
            else {
                    messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                    return
            }
            self.registerWeChat(appId: appId)
            self.wechatLogin(scope: scope, state: state)
        }
        
        // MARK: QQ分享 网页
        func shareQQWeb() {
            guard
                let title = params["title"],
                let description = params["description"],
                let previewImageUrl = params["previewImageUrl"],
                let webPageURL = params["webPageURL"],
                let shareType = UInt32(params["shareType"] ?? "1")
            else {
                messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                return
            }
            self.share_qq_Web(title: title, description: description, previewImageUrl: previewImageUrl, webPageURL: webPageURL, shareType: ShareDestType(rawValue: shareType))
        }
        
        // MARK: 微信分享 网页
        func shareWXWeb() {
            guard
                let appId = params["appId"],
                let title = params["title"],
                let description = params["description"],
                let imageUrlStr = params["imageUrl"],
                let webPageURL = params["webPageURL"],
                let scene = UInt32(params["scene"] ?? "0")
            else {
                messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                return
            }
            self.registerWeChat(appId: appId)
            var image: UIImage = UIImage()
            if
                let imageURL = URL(string: imageUrlStr),
                let data = try? Data(contentsOf: imageURL)
            {
                image = UIImage(data: data) ?? UIImage()
            }
            
            self.share_wechat_Web(title: title, description: description, image: image , webPageURL: webPageURL, scene: WXScene(rawValue: scene))
            
        }
        
        // MARK: 支付宝支付
        func payAliPay() {
            guard
                let orderString = params["orderString"],
                let appScheme = params["appScheme"]
            else {
                messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                return
            }
            self.pay_alipay(orderString: orderString, appScheme: appScheme)
        }
        
        // MARK: 微信支付
        func wxPay() {
            guard
                let appId = params["appId"],
                let partnerId = params["partnerId"],
                let prepayId = params["prepayId"],
                let package = params["package"],
                let nonceStr = params["nonceStr"],
                let timestamp = params["timestamp"],
                let sign = params["sign"]
            else {
                    messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                    return
            }
            self.registerWeChat(appId: appId)
            self.pay_wechat(partnerId: partnerId, prepayId: prepayId, package: package, nonceStr: nonceStr, timestamp: timestamp, sign: sign)
        }
        
        if let fun_type = RespH5Type(rawValue: message.name) {
            switch fun_type {
            case .login_QQ:
                qqLogin()
            case .login_WeChat:
                wxLogin()
            case .share_QQ_Web:
                shareQQWeb()
            case .share_WeChat_Web:
                shareWXWeb()
            case .pay_Alipay:
                payAliPay()
            case .pay_WeChat:
                wxPay()
            }
        } else {
            messageHappend(reqType: .nativeError, message: "没有找到调用的方法", messageLevel: .error, params: nil)
        }
        
    }
    
}










