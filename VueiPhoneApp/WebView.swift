//
//  WKWebView+CoderInit.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/3.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import WebKit


class WebView: WKWebView {
    
    required init?(coder: NSCoder) {
        
        if let _view = UIView(coder: coder) {
            
            super.init(frame: UIScreen.main.bounds, configuration: WKWebViewConfiguration())
            autoresizingMask = _view.autoresizingMask
            contentMode = _view.contentMode
            translatesAutoresizingMaskIntoConstraints = _view.translatesAutoresizingMaskIntoConstraints
            
        } else {
            return nil
        }
    }
    
    func loadUrl(string: String) {
        if let url = URL(string: string) {
            load(URLRequest(url: url))
        }
    }
}
