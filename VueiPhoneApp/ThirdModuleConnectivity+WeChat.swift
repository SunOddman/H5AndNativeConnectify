//
//  ThirdModuleConnectivity+WeChat.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/4.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import Foundation

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
