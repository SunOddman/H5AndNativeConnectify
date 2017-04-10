//
//  ThirdModuleConnectivity+Tencent.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/4.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import Foundation

// WARNING: 更换APPID 要去改 Scheme：tencent101251367

// MARK:- 腾讯QQ
class TencentConnectivity: NSObject, TencentSessionDelegate {
    
    
    var tencentOauth: TencentOAuth?
    
    /// 登录 - QQ
    func tencentLogin(appId: String, permission: [String]) {
        
//        let permission = ["get_user_info","get_simple_userinfo", "add_t"];
        //        self.tencentOauth = TencentOAuth(appId: tencentAppId, andDelegate: self)
        self.tencentOauth = TencentOAuth(appId: appId, andDelegate: self)
        self.tencentOauth?.authShareType = AuthShareType_QQ
        self.tencentOauth?.authorize(permission)
        
    }
    // Tencent Delegate
    func tencentDidLogin() {
        
        ThirdModuleConnectivity.shared.messageHappend(reqType: .qqLogin, message: "QQ授权成功", messageLevel: .log, params: nil)

        self.tencentOauth?.getUserInfo() // 获取用户信息
        
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        if response.retCode == Int32(URLREQUEST_SUCCEED.rawValue), let userInfo = response.jsonResponse {
            print(userInfo)
            
            let nickname = "\(userInfo["nickname"] ?? "")"
            let openid = self.tencentOauth?.openId ?? ""
            
            let params = [
                "nickname": nickname,
                "openid": openid
            ]
            
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqLogin, message: "获取用户信息成功", messageLevel: .success, params: params)
        } else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqLogin, message: "获取用户信息失败", messageLevel: .failed, params: ["response": "\(response.jsonResponse)"])
        }
    }
    
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        if cancelled {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqLogin, message: "用户取消登录", messageLevel: .alert, params: nil)
        } else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqLogin, message: "登录失败", messageLevel: .failed, params: nil)
        }
    }
    
    func tencentDidNotNetWork() {
        ThirdModuleConnectivity.shared.messageHappend(reqType: .commonMsg, message: "无网络连接,请检查网络", messageLevel: .warning, params: nil)
    }
    
    // MARK: QQ分享
    
    func share_qq_Text(text: String, shareType: ShareDestType = ShareDestTypeQQ) {
        let txtObj = QQApiTextObject(text: text)
        txtObj?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: txtObj)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Image(imageData: Data, previewImageData: Data, title: String, description: String, shareType: ShareDestType = ShareDestTypeQQ) {
        let img = QQApiImageObject(data: imageData, previewImageData: previewImageData, title: title, description: description)
        img?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: img)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Web(title: String, description: String, previewImageData: Data, webPageURL: String, shareType: ShareDestType = ShareDestTypeQQ) {
        
        guard let url = URL(string: webPageURL) else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "分享地址连接不正确", messageLevel: .error, params: nil)
            return
        }
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageData: previewImageData, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
    func share_qq_Web(title: String, description: String, previewImageUrl: String, webPageURL: String, shareType: ShareDestType = ShareDestTypeQQ) {
        
        guard let url = URL(string: webPageURL) else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "分享地址连接不正确", messageLevel: .error, params: nil)
            return
        }
        
        guard let previewUrl = URL(string: previewImageUrl) else {
            ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "预览图片地址不正确", messageLevel: .error, params: nil)
            return
        }
        
        let web = QQApiNewsObject(url: url, title: title, description: description, previewImageURL: previewUrl, targetContentType: QQApiURLTargetTypeNews)
        web?.shareDestType = shareType
        
        let req = SendMessageToQQReq(content: web)
        
        let resultCode: QQApiSendResultCode = QQApiInterface.send(req)
        ThirdModuleConnectivity.shared.messageHappend(reqType: .qqShare, message: "QQ分享返回结果：\(resultCode)", messageLevel: .success, params: nil)
    }
    
}
