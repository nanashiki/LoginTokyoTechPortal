//
//  BrowserViewController.swift
//  LoginTokyoTechPortal
//
//  Created by nana_dotApp on 2015/11/21.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit
import LoginTokyoTechPortal
import SVProgressHUD

class BrowserViewController: UIViewController,UIWebViewDelegate {
    @IBOutlet weak var wv: UIWebView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var goBackBtn: UIBarButtonItem!
    @IBOutlet weak var goForwardBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        wv.isOpaque = false
        self.wv.scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 44.0, 0.0)
        self.wv.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0, 0.0, 44.0, 0.0)
        NotificationCenter.default.addObserver(self, selector: #selector(BrowserViewController.didFinishLogin), name: NSNotification.Name(rawValue: LoginNotification.success.rawValue), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LoginNotification.success.rawValue), object: nil)
    }
    
    @IBAction func setBtnAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "Setting", sender: nil)
    }
    
    @IBAction func reloginBtnAction(_ sender: AnyObject) {
        Login.sharedInstance.start(completion: nil)
    }
    
    func positionForBar(_ bar:UIBarPositioning) -> UIBarPosition{
        return .topAttached
    }
    
    func didFinishLogin(){
        self.wv.loadRequest(URLRequest(url: URL(string: "https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList")!))
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        goBackBtn.isEnabled = wv.canGoBack
        goForwardBtn.isEnabled = wv.canGoForward
        navBar.topItem?.title = wv.stringByEvaluatingJavaScript(from: "document.title")
    }
    
    
}
