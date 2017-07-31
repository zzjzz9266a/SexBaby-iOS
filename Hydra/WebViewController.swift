//
//  WKWebViewController.swift
//  HeyFriday
//
//  Created by 吕文翰 on 16/6/20.
//  Copyright © 2016年 北京一米购科技有限公司. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var orderId = 0
    //    var user: User!
    
    var showConfirmOrderButton = true
    var url: String!
    var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationItems()
        
        if let percentUrl = self.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: percentUrl) {
            var request = URLRequest(url: url)
            request.setValue("ASPSESSIONIDCQDQQQQA=EAGHFNKBDDDMFALJLAJBPCLL; ASPSESSIONIDAQBSRRRB=BNDFGHEBAEPJELCHCMPGOIHN; usercookies%5F873983=dayarticlenum=0&daysoftnum=0&userip=47%2E88%2E11%2E132; ASPSESSIONIDCQARQRQA=NLIDGAOBOPLOFCEOLGJBPMAG; ASPSESSIONIDCSBSRQQA=DNHJEKHBCLJFAJNFJDEAGFLI; ASPSESSIONIDASDRRRRB=MMANJDBCJOELEIEOBFMBGBHP; NewAspUsers=RegDateTime=2017%2D07%2D27+00%3A19%3A45&UserToday=0%2C0%2C0%2C0%2C0%2C0&userlastip=223%2E255%2E127%2E36&UserGroup=%C6%D5%CD%A8%BB%E1%D4%B1&usermail=my%40email%2Ecom&UserLogin=7&UserGrade=1&password=4c9ea2b7ef321612&UserClass=0&username=zzjzz9266a&nickname=zzjzz9266a&usercookies=0&userid=873983&LastTime=2017%2D7%2D29+16%3A08%3A34&LastTimeIP=223%2E255%2E127%2E36&LastTimeDate=2017%2D7%2D29+16%3A08%3A34Host:www.weike27.com", forHTTPHeaderField: "Cookie")
            self.wkWebView.load(request)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        wkWebView.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    func setupUI(){
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        //        config.userContentController.add(self, name: "iosImageClick")     //内存泄露
        config.preferences = WKPreferences()
        
        self.wkWebView = WKWebView(frame: self.navigationController == nil ? CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight) : self.view.frame, configuration: config)
        self.wkWebView.navigationDelegate = self
        self.wkWebView.uiDelegate = self
        self.view.addSubview(wkWebView)
    }
    
    func setupNavigationItems(){
        if !self.showConfirmOrderButton {
            _ = self.navigationItem.rightBarButtonItems?.popLast()
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let url = navigationAction.request.url
            if url?.description.range(of: "mailto:") != nil || url?.description.range(of: "tel:") != nil  {
                UIApplication.shared.openURL(url!)
            }else {
                self.justShowWKWebViewController(fromVC: self, url: navigationAction.request.url?.description ?? "")
            }
        }
        return nil
    }
    

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        let title = webView.title != "" ? webView.title : webView.url?.absoluteString
        self.title = title
    }
    
    @IBAction func exitButtonBeTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func share() {

    }

}


extension UIResponder{
    
    func justShowWKWebViewController(fromVC: UIViewController, url: String, share: Bool = true) {
        let vc = WKWebViewController()
        vc.url = url
        fromVC.show(vc, sender: self)
        
        if share{
            let shareButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            shareButton.setImage(UIImage(named: "share")?.withRenderingMode(.alwaysTemplate), for: .normal)
            shareButton.tintColor = UIColor.blue
            shareButton.addTarget(vc, action: #selector(WKWebViewController.share), for: .touchUpInside)
            let rightItemShare = UIBarButtonItem(customView: shareButton)
            vc.navigationItem.rightBarButtonItem = rightItemShare
        }
        
    }
}
