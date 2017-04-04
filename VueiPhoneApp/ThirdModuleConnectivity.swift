//
//  ThirdModuleConnectivity.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/2.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import UIKit
import WebKit

// 腾讯QQ
let tencentAppId = "1106080432"
let tencentAppKey = "cV3wAzH1GDuXVKjj"
let permission = ["get_user_info","get_simple_userinfo", "add_t"];

// 微信
let weChatAppId = ""


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
        print("\(messageLevel): \(message)")
        
        // TODO: 给H5发送消息
        let reqParams = ["\(message)", "\(messageLevel)", "\(params ?? [:])"]
        
        webVc.executeH5Function(functionName: reqType.rawValue,
                                params: reqParams) { (result: Any?, error: Error?) in
                
        }
    }
    
}

// MARK:-
extension ThirdModuleConnectivity: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("H5调用本地方法：【\(message.name)】，参数：【\(message.body)】")
        
        let params = message.body as? [String : String] ?? [:]
        
        // MARK: QQ登录
        func qqLogin() {
            guard
                let appId = params["appId"]
            else {
                messageHappend(reqType: .nativeError, message: "参数错误", messageLevel: .error, params: nil)
                return
            }
            self.tencentLogin(appId: appId)
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


// MARK:- 腾讯QQ
extension ThirdModuleConnectivity: TencentSessionDelegate {
    
    /// 登录 - QQ
    func tencentLogin(appId: String) {
        
//        self.tencentOauth = TencentOAuth(appId: tencentAppId, andDelegate: self)
        self.tencentOauth = TencentOAuth(appId: appId, andDelegate: self)
        self.tencentOauth?.authShareType = AuthShareType_QQ
        self.tencentOauth?.authorize(permission)
        
    }
    // Tencent Delegate
    func tencentDidLogin() {
        messageHappend(reqType: .otherLoginSuccess, message: "QQ登录成功", messageLevel: .success, params: nil)
        self.tencentOauth?.getUserInfo() // 获取用户信息
        
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        if response.retCode == Int32(URLREQUEST_SUCCEED.rawValue) {
            let userInfo = response.jsonResponse
            print(userInfo ?? "")
            messageHappend(reqType: .otherLoginSuccess, message: "获取用户信息成功", messageLevel: .success, params: nil)
        } else {
            messageHappend(reqType: .nativeError, message: "获取用户信息失败", messageLevel: .failed, params: nil)
        }
    }
    
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        if cancelled {
            messageHappend(reqType: .nativeError, message: "用户取消登录", messageLevel: .alert, params: nil)
        } else {
            messageHappend(reqType: .nativeError, message: "登录失败", messageLevel: .failed, params: nil)
        }
    }
    
    func tencentDidNotNetWork() {
        messageHappend(reqType: .nativeError, message: "无网络连接,请检查网络", messageLevel: .warning, params: nil)
    }
    
    // MARK: QQ分享
    
    func share_qq_Text(text: String, shareType: ShareDestType = ShareDestTypeQQ) {
        let txtObj = QQApiTextObject(text: text)
        txtObj?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: txtObj)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(reqType: .shareSuccess, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Image(imageData: Data, previewImageData: Data, title: String, description: String, shareType: ShareDestType = ShareDestTypeQQ) {
        let img = QQApiImageObject(data: imageData, previewImageData: previewImageData, title: title, description: description)
        img?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: img)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(reqType: .shareSuccess, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Web(title: String, description: String, previewImageData: Data, webPageURL: String, shareType: ShareDestType = ShareDestTypeQQ) {
        
        guard let url = URL(string: webPageURL) else {
            messageHappend(reqType: .nativeError, message: "分享地址连接不正确", messageLevel: .error, params: nil)
            return
        }
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageData: previewImageData, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(reqType: .shareSuccess, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Web(title: String, description: String, previewImageUrl: String, webPageURL: String, shareType: ShareDestType = ShareDestTypeQQ) {
        
        guard let url = URL(string: webPageURL) else {
            messageHappend(reqType: .nativeError, message: "分享地址连接不正确", messageLevel: .error, params: nil)
            return
        }
        
        guard let previewUrl = URL(string: previewImageUrl) else {
            messageHappend(reqType: .nativeError, message: "预览图片地址不正确", messageLevel: .error, params: nil)
            return
        }
        
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageURL: previewUrl, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(reqType: .shareSuccess, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
}

// MARK:- 微信
extension ThirdModuleConnectivity: WXApiDelegate {
    
    func registerWeChat(appId: String) {
//        if WXApi.registerApp(weChatAppId) {
        if WXApi.registerApp(appId) {
            messageHappend(reqType: .nativeError, message: "微信注册成功", messageLevel: .success, params: nil)
        } else {
            messageHappend(reqType: .nativeError, message: "微信注册失败", messageLevel: .failed, params: nil)
        }
    }
    
    func wechatLogin(scope: String, state: String) {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let wechatAuthReq = SendAuthReq()
//            wechatAuthReq.scope = "snsapi_userinfo"
//            wechatAuthReq.state = "HDLApp"
            wechatAuthReq.scope = scope
            wechatAuthReq.state = state
            WXApi.send(wechatAuthReq)
        } else {
            messageHappend(reqType: .nativeError, message: "微信没有安装或微信版本不支持", messageLevel: .failed, params: nil)
        }
    }
    
    /// APP请求微信
    func onReq(_ req: BaseReq!) {
        messageHappend(reqType: .nativeError, message: "请求微信: \(req)", messageLevel: .log, params: nil)
    }
    
    /// 请求微信回调
    func onResp(_ resp: BaseResp!) {
        
        func filterFiled() {
            
            switch WXErrCode(resp.errCode) {
            case WXErrCodeSentFail:
                messageHappend(reqType: .nativeError, message: "请求发送失败", messageLevel: .error, params: nil)
                return
            case WXErrCodeAuthDeny:
                messageHappend(reqType: .nativeError, message: "微信授权失败", messageLevel: .failed, params: nil)
                return
            case WXErrCodeUnsupport:
                messageHappend(reqType: .nativeError, message: "微信版本不支持", messageLevel: .error, params: nil)
                return
            case WXErrCodeUserCancel:
                messageHappend(reqType: .nativeError, message: "用户取消", messageLevel: .failed, params: nil)
                return
            case WXErrCodeCommon:
                messageHappend(reqType: .nativeError, message: "发生错误", messageLevel: .failed, params: nil)
                return
            default:
                break
            }
            
        }
        
        messageHappend(reqType: .nativeError, message: "请求微信回调:\(resp)", messageLevel: .log, params: nil)
        
        if let authResp: SendAuthResp = resp as? SendAuthResp {
            
            filterFiled()
            messageHappend(reqType: .nativeError, message: "微信授权：\(authResp)", messageLevel: .success, params: nil)
            
        } else if let messageResp: SendMessageToWXResp = resp as? SendMessageToWXResp {
            
            filterFiled()
            messageHappend(reqType: .shareSuccess, message: "发送消息返回结果:\(messageResp)", messageLevel: .success, params: nil)
            
        } else if let addCardResp: AddCardToWXCardPackageResp = resp as? AddCardToWXCardPackageResp {
            
            filterFiled()
            messageHappend(reqType: .addCard, message: "添加卡券消息返回结果:\(addCardResp)", messageLevel: .success, params: nil)
            
        } else if let chooseCardResp: WXChooseCardResp = resp as? WXChooseCardResp {
            
            filterFiled()
            messageHappend(reqType: .chooseCard, message: "选择卡券:\(chooseCardResp)", messageLevel: .success, params: nil)
            
        } else if let payResp: PayResp = resp as? PayResp {
            
            filterFiled()
            messageHappend(reqType: .paySuccess, message: "支付成功\(payResp)", messageLevel: .success, params: nil)
            
        }
        
    }
    
    // MARK: 微信分享
    
    func share_wechat_Text(text: String, scene: WXScene) {
        let req = SendMessageToWXReq()
        req.text = text
        req.bText = true
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
    
    func share_wechat_Image(image: UIImage, scene: WXScene) {
        let message = WXMediaMessage()
        message.setThumbImage(image)
        let imgObj = WXImageObject()
        imgObj.imageData = UIImagePNGRepresentation(image)
        message.mediaObject = imgObj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
    
    func share_wechat_Web(title: String, description: String, image: UIImage, webPageURL: String, scene: WXScene) {
        let message = WXMediaMessage()
        message.title = title
        message.description = description
        message.setThumbImage(image)
        
        let webPageObj = WXWebpageObject()
        webPageObj.webpageUrl = webPageURL
        message.mediaObject = webPageObj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
    
    func share_wechat_miniApp(webPageUrl: String, userName: String, path: String, title: String, description: String, scene: WXScene) {
        let wxMiniObj = WXMiniProgramObject()
        wxMiniObj.webpageUrl = webPageUrl
        wxMiniObj.userName = userName
        wxMiniObj.path = path
        
        let message = WXMediaMessage()
        message.title = title
        message.description = description
        message.mediaObject = wxMiniObj
        message.setThumbImage(UIImage())
        
        let req = SendMessageToWXReq()
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
    
    // MARK: 微信支付
    func pay_wechat(partnerId: String, prepayId: String, package: String?, nonceStr: String, timestamp: String, sign: String) {
        guard let timeStampTime = UInt32(timestamp) else {
            messageHappend(reqType: .nativeError, message: "时间戳timestamp有误\(timestamp)", messageLevel: .error, params: nil)
            return
        }
        // 先调用 统一下单API： https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=9_1， 获得 prepay_id后传给APP
        let req = PayReq()
        req.partnerId = partnerId
        req.prepayId = prepayId
        req.package = package ?? "Sign=WXPay"
        req.nonceStr = nonceStr
        req.timeStamp = timeStampTime
        req.sign = sign
        
        WXApi.send(req)
    }
}

// MARK:- 支付宝
extension ThirdModuleConnectivity {
    
    func pay_alipay(appId: String,
                    method: String,
                    format: String,
                    return_url: String,
                    charset: String,
                    timestamp: String,
                    version: String,
                    notify_url: String,
                    app_auth_token: String,
                    signtype: String,
                    biz_content_body: String,
                    biz_content_subject: String,
                    biz_content_out_trade_no: String,
                    biz_content_timeout_express: String,
                    biz_content_total_amount: String,
                    biz_content_product_code: String,
                    biz_content_seller_id: String,
                    sign: String,
                    appScheme: String
        ) {
        let order = AliOrder()
        
        order.app_id = appId
        order.method = method
        order.format = format
        order.return_url = return_url
        order.charset = charset
        order.timestamp = timestamp
        order.version = version
        order.notify_url = notify_url
        order.app_auth_token = app_auth_token
        order.sign_type = signtype
        
        order.biz_content.body = biz_content_body
        order.biz_content.subject = biz_content_subject
        order.biz_content.out_trade_no = biz_content_out_trade_no
        order.biz_content.timeout_express = biz_content_timeout_express
        order.biz_content.total_amount = biz_content_total_amount
        order.biz_content.seller_id = biz_content_seller_id
        order.biz_content.product_code = biz_content_product_code
        
        let orderInfoEncoded = order.orderInfoEncoded(true)
        
        let orderString = "\(orderInfoEncoded ?? "")&sign=\(sign)"
        
        pay_alipay(orderString: orderString, appScheme: appScheme)
    }
    
    func pay_alipay(orderString: String, appScheme: String) {
        messageHappend(reqType: .nativeError, message: "支付宝请求:\(orderString)", messageLevel: .log, params: nil)
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme) { (resultDic: [AnyHashable : Any]?) in
            self.messageHappend(reqType: .paySuccess, message: "支付宝支付结果:\(resultDic ?? ["": ""])", messageLevel: .success, params: nil)
        }
    }
}






