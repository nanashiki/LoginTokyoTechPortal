//
//  LoginTitanetWireless.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/11.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

public enum LoginTitanetWirelessStatus : Int{
    case Init
    case NowLogin
    case NetworkError
    case TopPageNG
    case AccountPasswordNG
    case Success
}

public enum FinishLoginTitanetWirelessNotification : String{
    case success = "LoginTitanetWirelessSuccess"
}

public class LoginTitanetWireless: NSObject {
    //SharedInstance
    public static let sharedInstance = LoginTitanetWireless()
    
    //LoginInfo
    public var loginInfo = LoginInfo(account: nil, password: nil, matrixcode: nil)
    
    //Status
    public private (set) var status:LoginTitanetWirelessStatus = .Init
    
    //LoginDic
    let loginTWDic : [String:String]
    
    override private init() {
        if let path = NSBundle(forClass: self.dynamicType).pathForResource("LoginTitanetWireless", ofType: "plist"){
            if let dic : [String:String] = NSDictionary(contentsOfFile: path) as? [String:String]{
                loginTWDic = dic
            }else{
                loginTWDic = Dictionary()
            }
        }else{
            loginTWDic = Dictionary()
        }
    }
    
    public func start(completion completion:((LoginTitanetWirelessStatus)->())){
        if status == .NowLogin{
            completion(self.status)
            return
        }
        self.status = .NowLogin
        self.login_TopPage(completion: {
            success,html in
            if !success {
                completion(self.status)
                return
            }
            self.login_AccountPassword(html: html, account: self.loginInfo.account, password: self.loginInfo.password, completion: {
                success ,html in
                completion(self.status)
                if success{
                    NSNotificationCenter.defaultCenter().postNotificationName(FinishLoginTitanetWirelessNotification.success.rawValue, object: nil)
                }
            })
            
        })
    }
    
    private func login_TopPage(completion completion:((Bool,String)->())){
        HTTPConnection.getStringFromGETRequest(loginTWDic["TopPageURL"],timeout: 3.0, completion:{html_ in
            if let html = html_{
                if html.containsString(self.loginTWDic["TopPageConfirmString"]){
                    print("TopPage_TW OK")
                    completion(true,html)
                }else{
                    print("TopPage_TW NG")
                    self.status = .TopPageNG
                    completion(false,html)
                }
            }else{
                print("Can't access Titanet Wireless")
                self.status = .NetworkError
                completion(false,"")
            }
        })
    }
    
    private func login_AccountPassword(html html : String ,account : String, password: String,completion:((Bool,String)->())){
        var postStr = HTTPConnection.getPOSTStringFromHTML(html)
        postStr = postStr.addString(account, afterString: loginTWDic["usr_name="])
        postStr = postStr.addString(password.escapeStr(), afterString: loginTWDic["usr_password="])
        HTTPConnection.getStringFromPOSTRequest(url:loginTWDic["PostURL"], post: postStr, referer:loginTWDic["TopPageURL"] ?? "",timeout: nil ,completion: {html_ in
            if let html = html_{
                if html.containsString(self.loginTWDic["AccountPasswordConfirmString"]){
                    print("AccountPassword_TW OK")
                    self.status = .Success
                    completion(true,html)
                }else{
                    print("AccountPassword_TW NG")
                    self.status = .AccountPasswordNG
                    completion(false,html)
                }
            }else{
                self.status = .NetworkError
                completion(false,"")
            }
        })
        
    }
    
}
