//
//  ThirdModuleConnectivity+WeChat.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/4.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import Foundation

// MARK:- 微信
class WeChatConnectivity: NSObject, WXApiDelegate {
    
    var appId: String = ""
    var appSecret: String = ""
    
    func registerWeChat(appId: String, appSecret: String) {
        self.appId = appId
        self.appSecret = appSecret
        
        if WXApi.registerApp(appId) {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "微信注册成功", messageLevel: .success, params: nil)
        } else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "微信注册失败", messageLevel: .failed, params: nil)
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
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "微信没有安装或微信版本不支持", messageLevel: .failed, params: nil)
        }
    }
    
    /// APP请求微信
    func onReq(_ req: BaseReq!) {
        ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "请求微信: \(req)", messageLevel: .log, params: nil)
    }
    
    /// 请求微信回调
    func onResp(_ resp: BaseResp!) {
        
        func filterFiled() -> Bool {
            
            switch WXErrCode(resp.errCode) {
            case WXErrCodeSentFail:
                ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "请求发送失败", messageLevel: .error, params: nil)
                return false
            case WXErrCodeAuthDeny:
                ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "微信授权失败", messageLevel: .failed, params: nil)
                return false
            case WXErrCodeUnsupport:
                ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "微信版本不支持", messageLevel: .error, params: nil)
                return false
            case WXErrCodeUserCancel:
                ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "用户取消", messageLevel: .failed, params: nil)
                return false
            case WXErrCodeCommon:
                ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "发生错误", messageLevel: .failed, params: nil)
                return false
            default:
                return true
            }
        }
        
        func auth(authResp: SendAuthResp) {
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "微信授权：\(authResp)", messageLevel: .success, params: nil)
            
            // 请求 openId
            // https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
            let openIdUrl = URL(string: "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(self.appId)&secret=\(self.appSecret)&code=\(authResp.code!)&grant_type=authorization_code")!
            guard let openIdData = try? Data(contentsOf: openIdUrl) else {
                ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "请求微信openId失败：\(openIdUrl)", messageLevel: .failed, params: nil)
                return
            }
            let openIdJson = try? JSONSerialization.jsonObject(with: openIdData, options: .mutableContainers)
            let openIdDic = (openIdJson as? NSDictionary) ?? NSDictionary()
            if let errcode = openIdDic.object(forKey: "errcode") {
                let error = String(data: openIdData, encoding: .utf8) ?? errcode
                ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "请求微信openId报错:\(openIdUrl)\n Error:\(error))", messageLevel: .failed, params: nil)
                return
            }
            let openId = (openIdDic.object(forKey: "openid") ?? "") as! String
            let access_token = (openIdDic.object(forKey: "access_token") ?? "") as! String
            
            // 请求用户昵称
            // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
            let userInfoUrl = URL(string: "https://api.weixin.qq.com/sns/userinfo?access_token=\(access_token)&openid=\(openId)")!
            guard let userInfoData = try? Data(contentsOf: userInfoUrl) else {
                ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "请求微信用户信息失败：\(userInfoUrl)", messageLevel: .failed, params: nil)
                return
            }
            let userInfoJson = try? JSONSerialization.jsonObject(with: userInfoData, options: .mutableContainers)
            let userInfoDic = (userInfoJson as? NSDictionary) ?? NSDictionary()
            if let errcode = openIdDic.object(forKey: "errcode") {
                let error = String(data: userInfoData, encoding: .utf8) ?? errcode
                ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "请求微信用户信息报错:\(userInfoUrl)\n Error:\(error))", messageLevel: .failed, params: nil)
                return
            }
            let nickName = (userInfoDic.object(forKey: "nickname") ?? "") as! String
            
            // 传给H5
            let params = [
                "nickname": nickName,
                "openid": openId
            ]
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatLogin, message: "微信登录成功", messageLevel: .success, params: params)
            
        }
        
        ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "请求微信回调:\(resp)", messageLevel: .log, params: nil)
        
        // MARK: 过滤错误
        if !filterFiled() {
            return
        }
        
        if let authResp: SendAuthResp = resp as? SendAuthResp {
            // MARK: 微信授权
            
            auth(authResp: authResp)
            
        } else if let messageResp: SendMessageToWXResp = resp as? SendMessageToWXResp {
            // MARK: 分享
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatShare, message: "发送消息返回结果:\(messageResp)", messageLevel: .success, params: nil)
            
        } else if let addCardResp: AddCardToWXCardPackageResp = resp as? AddCardToWXCardPackageResp {
            // MARK: 添加卡券
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .addCard, message: "添加卡券消息返回结果:\(addCardResp)", messageLevel: .success, params: nil)
            
        } else if let chooseCardResp: WXChooseCardResp = resp as? WXChooseCardResp {
            // MARK: 选择卡券
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .chooseCard, message: "选择卡券:\(chooseCardResp)", messageLevel: .success, params: nil)
            
        } else if let payResp: PayResp = resp as? PayResp {
            // MARK: 支付
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatPay, message: "支付成功\(payResp)", messageLevel: .success, params: nil)
            
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
            ThirdModuleConnectivity.shared.messageHappend(reqType: .weChatPay, message: "时间戳timestamp有误\(timestamp)", messageLevel: .error, params: nil)
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
