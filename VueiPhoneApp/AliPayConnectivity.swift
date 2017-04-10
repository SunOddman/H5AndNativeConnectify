//
//  ThirdModuleConnectivity+Alipay.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/4.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import Foundation

// MARK:- 支付宝
class AliPayConnectivity {
    
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
        ThirdModuleConnectivity.shared.messageHappend(reqType: .aliPay, message: "支付宝请求:\(orderString)", messageLevel: .log, params: nil)
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme) { (resultDic: [AnyHashable : Any]?) in
            ThirdModuleConnectivity.shared.messageHappend(reqType: .aliPay, message: "支付宝支付结果:\(resultDic ?? ["": ""])", messageLevel: .success, params: nil)
        }
    }
}
