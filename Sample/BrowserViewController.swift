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
        wv.opaque = false
        self.wv.scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 44.0, 0.0)
        self.wv.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0, 0.0, 44.0, 0.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLogin", name: LoginNotification.success.rawValue, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginNotification.success.rawValue, object: nil)
    }
    
    @IBAction func setBtnAction(sender: AnyObject) {
        self.performSegueWithIdentifier("Setting", sender: nil)
    }
    
    @IBAction func reloginBtnAction(sender: AnyObject) {
        Login.sharedInstance.start(completion: nil)
    }
    
    func positionForBar(bar:UIBarPositioning) -> UIBarPosition{
        return .TopAttached
    }
    
    func didFinishLogin(){
        self.wv.loadRequest(NSURLRequest(URL: NSURL(string: "https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList")!))
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        goBackBtn.enabled = wv.canGoBack
        goForwardBtn.enabled = wv.canGoForward
        navBar.topItem?.title = wv.stringByEvaluatingJavaScriptFromString("document.title")
    }
}
