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

enum MessageLevelType: Int {
    case log = -1
    case success = 0
    case warning = 1
    case alert = 2
    case failed = 3
    case error = 4
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
    
    
    func messageHappend(message: String, messageLevel: MessageLevelType) {
        print("\(messageLevel): \(message)")
        // TODO: 给H5发送Error
//        webVc.executeH5Function(functionName: <#T##String#>, params: <#T##[String]?#>, completionHandler: <#T##((Any?, Error?) -> Void)?##((Any?, Error?) -> Void)?##(Any?, Error?) -> Void#>)
    }
    
}

// MARK:-
extension ThirdModuleConnectivity: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("H5调用本地方法：【\(message.name)】，参数：【\(message.body)】")
        
    }
}


// MARK:- 腾讯QQ
extension ThirdModuleConnectivity: TencentSessionDelegate {
    
    func tencentLogin() {
        
        self.tencentOauth = TencentOAuth(appId: tencentAppId, andDelegate: self)
        self.tencentOauth?.authShareType = AuthShareType_QQ
        self.tencentOauth?.authorize(permission)
        
    }
    // Tencent Delegate
    func tencentDidLogin() {
        messageHappend(message: "QQ登录成功", messageLevel: .success)
        
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        if response.retCode == Int32(URLREQUEST_SUCCEED.rawValue) {
            let userInfo = response.jsonResponse
            print(userInfo ?? "")
            messageHappend(message: "获取用户信息成功", messageLevel: .success)
        } else {
            messageHappend(message: "获取用户信息失败", messageLevel: .failed)
        }
    }
    
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        if cancelled {
            messageHappend(message: "用户取消登录", messageLevel: .alert)
        } else {
            messageHappend(message: "登录失败", messageLevel: .failed)
        }
    }
    
    func tencentDidNotNetWork() {
        messageHappend(message: "无网络连接,请检查网络", messageLevel: .warning)
    }
    
    // MARK: QQ分享
    
    func share_qq_Text(text: String, shareType: ShareDestType) {
        let txtObj = QQApiTextObject(text: text)
        txtObj?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: txtObj)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(message: "QQ分享返回结果：\(resultCode)", messageLevel: .success)
    }
    
    func share_qq_Image(imageData: Data, previewImageData: Data, title: String, description: String, shareType: ShareDestType) {
        let img = QQApiImageObject(data: imageData, previewImageData: previewImageData, title: title, description: description)
        img?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: img)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(message: "QQ分享返回结果：\(resultCode)", messageLevel: .success)
    }
    
    func share_qq_Web(title: String, description: String, previewImageData: Data, webPageURL: String, shareType: ShareDestType) {
        
        guard let url = URL(string: webPageURL) else {
            messageHappend(message: "分享地址连接不正确", messageLevel: .error)
            return
        }
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageData: previewImageData, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(message: "QQ分享返回结果：\(resultCode)", messageLevel: .success)
    }
    
    func share_qq_Web(title: String, description: String, previewImageUrl: String, webPageURL: String, shareType: ShareDestType) {
        
        guard let url = URL(string: webPageURL) else {
            messageHappend(message: "分享地址连接不正确", messageLevel: .error)
            return
        }
        
        guard let previewUrl = URL(string: previewImageUrl) else {
            messageHappend(message: "预览图片地址不正确", messageLevel: .error)
            return
        }
        
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageURL: previewUrl, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        messageHappend(message: "QQ分享返回结果：\(resultCode)", messageLevel: .success)
    }
    
}

// MARK:- 微信
extension ThirdModuleConnectivity: WXApiDelegate {
    
    func registerWeChat() {
        if WXApi.registerApp(weChatAppId) {
            messageHappend(message: "微信注册成功", messageLevel: .success)
        } else {
            messageHappend(message: "微信注册失败", messageLevel: .failed)
        }
    }
    
    func wechatLogin() {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let wechatAuthReq = SendAuthReq()
            wechatAuthReq.scope = "snsapi_userinfo"
            wechatAuthReq.state = "HDLApp"
            WXApi.send(wechatAuthReq)
        } else {
            messageHappend(message: "微信没有安装或微信版本不支持", messageLevel: .warning)
        }
    }
    
    /// APP请求微信
    func onReq(_ req: BaseReq!) {
        messageHappend(message: "从微信请求: \(req)", messageLevel: .success)
    }
    
    /// 请求微信回调
    func onResp(_ resp: BaseResp!) {
        
        func filterFiled() {
            
            switch WXErrCode(resp.errCode) {
            case WXErrCodeSentFail:
                messageHappend(message: "请求发送失败", messageLevel: .error)
                return
            case WXErrCodeAuthDeny:
                messageHappend(message: "微信授权失败", messageLevel: .failed)
                return
            case WXErrCodeUnsupport:
                messageHappend(message: "微信版本不支持", messageLevel: .error)
                return
            case WXErrCodeUserCancel:
                messageHappend(message: "用户取消", messageLevel: .failed)
                return
            case WXErrCodeCommon:
                messageHappend(message: "发生错误", messageLevel: .failed)
                return
            default:
                break
            }
            
        }
        
        messageHappend(message: "请求微信回调:\(resp)", messageLevel: .log)
        
        if let authResp: SendAuthResp = resp as? SendAuthResp {
            
            filterFiled()
            messageHappend(message: "微信授权：\(authResp)", messageLevel: .success)
            
        } else if let messageResp: SendMessageToWXResp = resp as? SendMessageToWXResp {
            
            filterFiled()
            messageHappend(message: "发送消息返回结果:\(messageResp)", messageLevel: .success)
            
        } else if let addCardResp: AddCardToWXCardPackageResp = resp as? AddCardToWXCardPackageResp {
            
            filterFiled()
            messageHappend(message: "添加卡券消息返回结果:\(addCardResp)", messageLevel: .success)
            
        } else if let chooseCardResp: WXChooseCardResp = resp as? WXChooseCardResp {
            
            filterFiled()
            messageHappend(message: "选择卡券:\(chooseCardResp)", messageLevel: .success)
            
        } else if let payResp: PayResp = resp as? PayResp {
            
            filterFiled()
            messageHappend(message: "支付成功\(payResp)", messageLevel: .success)
            
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
            messageHappend(message: "时间戳timestamp有误\(timestamp)", messageLevel: .error)
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
        messageHappend(message: "支付宝请求:\(orderString)", messageLevel: .log)
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme) { (resultDic: [AnyHashable : Any]?) in
            self.messageHappend(message: "支付宝支付结果:\(resultDic ?? ["": ""])", messageLevel: .success)
        }
    }
}
