//
//  ThirdModuleConnectivity+Tencent.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/4.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import Foundation


// MARK:- 腾讯QQ
extension ThirdModuleConnectivity: TencentSessionDelegate {
    
    /// 登录 - QQ
    func tencentLogin(appId: String, permission: [String]) {
        
        let permission = ["get_user_info","get_simple_userinfo", "add_t"];
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
